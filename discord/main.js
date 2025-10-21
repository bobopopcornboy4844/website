let form = document.getElementById('sendF');
let url = 'http://mb-factors.gl.at.ply.gg:22538';
let msgs = {};
let msgsDIV = document.getElementById('mid');

async function postData(url, data) {
  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const responseData = await response.json();
    console.log('POST Success:', responseData);
    return responseData;
  } catch (error) {
    console.error('POST Error:', error);
  }
}

async function getData(url) {
  try {
    const response = await fetch(url, { method: 'GET' });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const responseData = await response.json();
    console.log('GET Success:', responseData);
    return responseData;
  } catch (error) {
    console.error('GET Error:', error);
  }
}

async function refreshMsgs() {
  try {
    msgs = await getData(url);
    if (!msgs) return;

    let channel = document.getElementById('channel').value;
    let channelMsgs = msgs[channel] || [];

    // ⚠️ FIXED: use innerHTML (not innerHtml)
    msgsDIV.innerHTML = '';

    for (let i = 0; i < channelMsgs.length; i++) {
      let v = channelMsgs[i];
      // Simple text append
      let msgEl = document.createElement('p');
      msgEl.textContent = v.username +':' + v.message;
      msgsDIV.appendChild(msgEl);
    }
  } catch (err) {
    console.error('Refresh failed:', err);
  }
}

// Automatically refresh every few seconds
setInterval(refreshMsgs, 5000);

async function send() {
  let text = document.getElementById('msg').value.trim();
  let username = document.getElementById('username').value.trim();
  let channel = document.getElementById('channel').value.trim();

  if (!text || !username || !channel) {
    alert("Please fill in all fields!");
    return;
  }

  let con = { message: text, username, channel };

  try {
    await postData(url, con);
    document.getElementById('msg').value = ''; // clear after send
    refreshMsgs(); // refresh messages after send
  } catch (err) {
    console.error("Failed to send message:", err);
  }
}

form.addEventListener('submit', function(event) {
  event.preventDefault();
  send();
});
