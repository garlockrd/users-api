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
        //Check if new account or invited user
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
            // Create Account bucket and user bucket
        } else {  // add user to account
            roleId = invite.roleId
            await invitedUserService.removeInvite(request.email, request.accountId);
        }

        // Insert into user DB    
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
        await userService.createUserS3Bucket(user.accountId, userId);

        if (invite == null) {
            await accountService.addToAccountHistoryQueue(accountId, "Account Created", userId, { accountId: accountId });
        } else {
            await accountService.addToAccountHistoryQueue(accountId, "User Accepted Invite", userId, { userId: userId });
        }

        await userService.createPasswordHistory(userId, user.hashedPassword);

        var userHistoryObj = {
            id: userId,
            email: user.email,
            accountId: user.accountId,
            roleId: user.roleId,
            firstName: user.firstName,
            lastName: user.lastName
        }
        await userService.addToUserHistoryQueue(userId, "User Created", userId, userHistoryObj);
        await emailService.addToEmailQueue(user.email, "Account Created", "New Account Created");

        // TO DO: refactor, write tests

        var response = { 
            accountId: accountId,
            invite: invite
        };

        return http.createResponseObject(200, response);
    } catch(err) {
        return http.createResponseObject(500, { 'message': err.message });
    }
}