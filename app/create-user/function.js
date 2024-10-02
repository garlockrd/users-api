const http = require('/opt/nodejs/http.service.js');

module.exports.handler = async (event) => {   
    let request = JSON.parse(event.body);

    try {
        //Check if account id exists and has invite

        // if new:
        // Insert into account DB
        // Put default permissions into Permission DB
        // Creat default Admin Role if new
        // Create Account bucket and user bucket

        // Insert into user DB

        // If invite
        // Remove from invited-user DB
        // Insert into password history DB

        // Put topic in account-history queue
        // New account or user added from invite

        // Put topic in user-history queue

        // Put topic in send-email queue

        return http.createResponseObject(200);
    } catch(err) {
        return http.createResponseObject(500, { 'message': err.message });
    }
}