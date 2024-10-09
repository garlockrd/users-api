const http = require('/opt/nodejs/http.service.js');
const invitedUserService = require('/opt/nodejs/invited-user.service.js');
const userService = require('/opt/nodejs/user.service.js');
const accountService = require('/opt/nodejs/account.service.js');
const permissionService = require('/opt/nodejs/permission.service.js');
const roleService = require('/opt/nodejs/role.service.js');
const authService = require('/opt/nodejs/auth.service.js');
const emailService = require('/opt/nodejs/email.service.js');

module.exports.handler = async (event) => {   
    let request = JSON.parse(event.body);

    try {
        var invite = null;
        if (request.accountId != undefined) {
            invite = await invitedUserService.getInvite(request.email, request.accountId);
        }

        var accountId = request.accountId;
        var roleId = undefined;
        if (invite == null) {  // New Account
            accountId = await accountService.createAccount({});
            const defaultPermissionList = await permissionService.createDefaultPermissions(accountId);
            roleId = await roleService.createDefaultAdminRole(accountId, defaultPermissionList);
            await accountService.createAccountS3Bucket(accountId);
        } else {  // add user to account
            roleId = invite.roleId
            await invitedUserService.removeInvite(request.email, request.accountId);
        }

        var user = await createUser(request, accountId, roleId);
        await addHistory(user, invite);        
        await emailService.addToEmailQueue(user.email, "Account Created", "New Account Created");

        var response = { accountId: accountId, userId: user.id };
        return http.createResponseObject(200, response);
    } catch(err) {
        return http.createResponseObject(500, { 'message': err.message });
    }
}

async function createUser(request, accountId, roleId) {
    const salt = authService.createSalt();
    let user = {
        email: request.email,
        accountId: accountId,
        hashedPassword:  authService.hashPassword(request.password, salt),
        salt: salt,
        roleId: roleId,
        firstName: request.firstName,
        lastName: request.lastName
    };
    let userId = await userService.createUser(user);
    user.id = userId;
    await userService.createUserS3Bucket(user.accountId, userId);
    return user;
}

async function addHistory(user, invite) {
    if (invite == null)
        await accountService.addToAccountHistoryQueue(user.accountId, "Account Created", user.id, { accountId: user.accountId });
    else 
        await accountService.addToAccountHistoryQueue(user.accountId, "User Accepted Invite", user.id, { userId: user.id });

    await userService.createPasswordHistory(user.id, user.hashedPassword);

    var userHistoryObj = {
        id: user.id,
        email: user.email,
        accountId: user.accountId,
        roleId: user.roleId,
        firstName: user.firstName,
        lastName: user.lastName
    }
    await userService.addToUserHistoryQueue(user.id, "User Created", user.id, userHistoryObj);
}