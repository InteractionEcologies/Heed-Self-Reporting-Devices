/**
 * Copyright 2015 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
'use strict';

const functions = require('firebase-functions');
const nodemailer = require('nodemailer');
const admin = require('firebase-admin');
var _ = require('underscore');

var moment = require('moment-timezone');

admin.initializeApp(functions.config().firebase);
// Configure the email transport using the default SMTP transport and a GMail account.
// For other types of transports such as Sendgrid see https://nodemailer.com/transports/
// TODO: Configure the `gmail.email` and `gmail.password` Google Cloud environment variables.
const gmailEmail = encodeURIComponent(functions.config().gmail.email);
const gmailPassword = encodeURIComponent(functions.config().gmail.password);
const mailTransport = nodemailer.createTransport(
    `smtps://${gmailEmail}:${gmailPassword}@smtp.gmail.com`);

// Your company name to include in the emails
// TODO: Change this to your app or company name to customize the email sent.
const APP_NAME = 'HEED';

// [START sendAdminEmail]
/**
 * Sends a welcome email to new user.
 */
// [START onCreateTrigger]

exports.sendemail = functions.https.onRequest((req, res) => {
  const user = "admin"; // The Firebase user.

  const email = "gparuthi@gmail.com"; // The email of the user.
  const displayName = "Gaurav"; // The display name of the user.
  // [END eventAttributes]

  sendAdminEmail(email, displayName);
  const formattedDate = (new Date()).toString();
  res.status(200).send(formattedDate);
});

exports.dailyemail = functions.https.onRequest((req, res) => {
 
  sendDailyEmailToUsers();
  res.status(200).send(moment().format("MMM Do"));
});



// Sends a welcome email to the given user.
function sendAdminEmail(email, displayName) {
  const mailOptions = {
    from: '"Gaurav" <gparuthi@umich.edu>',
    to: email
  };

  // The user unsubscribed to the newsletter.
  mailOptions.subject = `[HEED] Updates`;
  

  admin.database().ref('/logs').limitToLast(40).once("value", function(snapshot){
        console.log("Loaded 20");
        let allData = _.values(snapshot.val())
        let users = _.union(_.pluck(allData,'userId'))
        mailOptions.html = `<p> `+ users.join() +`</p>`;
        allData = _.map(allData, l=>{l.text = l.text.toString(); return l})
        let logtext = _.map(allData,d => {
                let hrsdiff = (moment()-moment(d.time))/1000/60/60
                return  Math.round(hrsdiff*10)/10  + " | " + d.userId + " | " + d.text  + "<br>"}
                ); 
        mailOptions.html += logtext;
        console.log(logtext);
        return mailTransport.sendMail(mailOptions).then(() => {
          console.log('New welcome email sent to:', email);
        });
      })
}

// // Sends a welcome email to the given user.
// function sendDailyEmailToUsers() {
//   const userlist = [{n: "Gaurav", u:"gparuthi", e: "gparuthi@gmail.com"},
//   {n: "Hari", u:"Harihars", e: "harihars@umich.edu"},
//   {n: "Allan", u:"allanmar", e: "allanmar@umich.edu"},
//     {n: "Shriti", u:"Shriti", e: "shritir@umich.edu"}]
//   let mailOptions = {
//     from: '"Gaurav" <gparuthi@umich.edu>',
//     subject: `[HEED] End of Day Diary `,
//     cc: "gparuthi@umich.edu"
//   };

//   _.each(userlist, user => {
//     mailOptions.to = user.e
//     mailOptions.html = `<p> Hey `+user.n+`,</p> <p>Thanks for participating in the study. </p><p>Please fill your end of day diary for `+moment().tz('America/New_York').format('MMMM Do')+` <a href="https://heed.intecolab.com/#diary/`+user.u+`">here</a>.</p>`;
//     mailTransport.sendMail(mailOptions).then(() => {
//         console.log('New welcome email sent to:', user);
//       });
//   })

  
//   return "done"
// }

// Sends a welcome email to the given user.
function sendDailyEmailToUsers() {
  const userlist = [{n: "Gaurav", u:"gparuthi", e: "gparuthi@gmail.com"},
  {n: "Linh", u:"lvnguyen", e: "nguyenvanlinh1992@gmail.com"},
  {n: "Srayan", u:"srayan", e: "srayan.datta@gmail.com"}
    ]
  let mailOptions = {
    from: '"Gaurav" <gparuthi@umich.edu>',
    subject: `[HEED] End of Day Diary `,
    cc: "gparuthi@umich.edu"
  };

  _.each(userlist, user => {
    mailOptions.to = user.e
    mailOptions.html = `<p> Hey `+user.n+`,</p> <p>Thanks for participating in the study. </p><p>Please fill your end of day diary for `+moment().tz('America/New_York').format('MMMM Do')+` <a href="https://heed.intecolab.com/#diary/`+user.u+`">here</a>.</p>`;
    mailTransport.sendMail(mailOptions).then(() => {
        console.log('New welcome email sent to:', user);
      });
  })

  
  return "done"
}
