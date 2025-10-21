let form = document.getElementById('sendF')
let url = 'http://mb-factors.gl.at.ply.gg:22538'
let msgs = {}
async function postData(url, data) {
  try {
    const response = await fetch(url, {
      method: 'POST', // Specify the HTTP method as POST
      headers: {
        'Content-Type': 'application/json' // Indicate that the request body is JSON
      },
      body: JSON.stringify(data) // Convert the JavaScript object to a JSON string
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const responseData = await response.json(); // Parse the JSON response
    console.log('Success:', responseData);
    return responseData;
  } catch (error) {
    console.error('Error:', error);
    throw error; // Re-throw the error for further handling
  }
}
async function getData(url) {
  try {
    const response = await fetch(url, {
      method: 'GET', // Specifyrt the JavaScript object to a JSON string
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const responseData = await response.json(); // Parse the JSON response
    console.log('Success:', responseData);
    return responseData;
  } catch (error) {
    console.error('Error:', error);
    throw error; // Re-throw the error for further handling
  }
}
msgsDIV = document.getElementById('mid')
async function refreshMsgs() {
  msgs = await getData(url);
  channelMsgs = msgs[document.getElementById('channel').value]
  msgsDIV.innerHtml = ''
  for (let i=0;i<channelMsgs.length;i++) {
    let v = channelMsgs[i]
    msgsDIV.innerHtml += '<a>'+v+'</a>'
  }
}
refreshMsgs()
async function send() {
  let text = document.getElementById('msg').value;
  let username = document.getElementById('username').value;
  let channel = document.getElementById('channel').value;
  let con = { message: text, username, channel };

  try {
    let res = await postData(url, con);
    console.log("Server response:", res);
  } catch (err) {
    console.error("Failed to send message:", err);
  }
}

form.addEventListener('submit', function(event) {
    event.preventDefault(); // Prevent default form submission
    send()
    console.log('Form submitted!');
});
