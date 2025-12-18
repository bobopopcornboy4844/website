var ThemeManager = (function() {
	var defaultColorScheme='dark',
		userColorScheme='',
		hasStorage=false,
		hasLocalStorage = typeof window.localStorage !== 'undefined',
		storageId='virtual6502Config';
	
	function colorSchemeChangeHandler(event) {
		defaultColorScheme = event.matches? 'dark':'light';
		setColorScheme(defaultColorScheme);
	}
	
	function setColorScheme(scheme) {
		document.body.className=scheme;
		document.getElementById('colorNavDark').setAttribute('aria-current',scheme=='dark');
		document.getElementById('colorNavLight').setAttribute('aria-current',scheme!='dark');
	}
	
	function setDarkMode(v) {
		userColorScheme = v? 'dark':'light';
		setColorScheme(userColorScheme);
		storageWrite();
	}
	
	//storage
	function storageRead() {
		function extract(s) {
			var rows=decodeURIComponent(s).split(',');
			for (var j=0; j<rows.length; j++) {
				var cols=rows[j].split(':');
				if (cols[0]=='theme') {
					userColorScheme = cols[1].toLowerCase()=='dark'?'dark':'light';
					hasStorage=true;
					break;
				}
			}
		}
		userColorScheme='';
		if (hasLocalStorage) {
			var s= localStorage.getItem(storageId);
			if (s) extract(s);
		}
		else if (!hasLocalStorage && document.cookie) {
			var	cookies = document.cookie.split(/;\s*/g);
			for (var i=0; i<cookies.length; i++) {
				var parts = cookies[i].split('=');
				if (parts[0]==storageId) {
					extract(parts[1]);
					break;
				}
			}
			if (hasStorage) write(); // update expiration date
		}
	}
	function storageWrite() {
		var q=[];
		q.push('theme:'+userColorScheme);
		if (hasLocalStorage) {
			localStorage.setItem(storageId, encodeURIComponent(q.join(',')));
		}
		else {
			var t=storageId+'='+encodeURIComponent(q.join(',')),
				expires=new Date(),
				path='/6502/',
				secure=(location.protocol.indexOf('https')==0)? 'secure=1':'';
			expires.setMilliseconds(expires.getMilliseconds() + 365 * 864e+5);
			t+='; expires='+expires.toUTCString();
			if (path) t+='; path='+path;
			if (secure) t+='; '+secure;
			document.cookie=t;
		}
		hasStorage=true;
	}
	function storageDestroy() {
		if (hasStorage) {
			if (hasLocalStorage) {
				localStorage.removeItem(storageId);
			}
			else {
				var t=storageId+'=; expires=Thu, 01 Jan 1970 00:00:00 GMT',
					path='/6502/',
					secure=(location.protocol.indexOf('https')==0)? 'secure=1':'';
				if (path) t+='; path='+path;
				if (secure) t+='; '+secure;
				document.cookie=t;
			}
			hasStorage=false;
		}
		userColorScheme='';
	}

	function initialize() {
		if (window.matchMedia) {
			var darkMatch = window.matchMedia('(prefers-color-scheme: dark)');
			if (darkMatch) {
				defaultColorSchme=darkMatch.matches? 'dark':'light';
				if (darkMatch.addEventListener) darkMatch.addEventListener('change', colorSchemeChangeHandler, false);
			}
		}
		storageRead();
		setColorScheme(userColorScheme || defaultColorScheme);
	}

	if (document.readyState === 'loading') {
		// wait for page to become interactive
		document.addEventListener('DOMContentLoaded', initialize, false);
	}
	else if (document.readyState) {
		// DOM is available (page loaded or interactive)
		initialize();
	}
	else {
		// fall-back for lagacy browsers
		window.onload = initialize;
	}

	return {
		'setDarkMode': setDarkMode,
		'reset': storageDestroy,
		'initialize': function() {} // dummy
	};
})();
