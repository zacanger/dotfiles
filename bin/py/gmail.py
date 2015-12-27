import mechanize
import cookielib
from BeautifulSoup import BeautifulSoup
import html2text

# Browser
br = mechanize.Browser()

# Cookie Jar
cj = cookielib.LWPCookieJar()
br.set_cookiejar(cj)

# Browser options
br.set_handle_equiv(True)
br.set_handle_gzip(True)
br.set_handle_redirect(True)
br.set_handle_referer(True)
br.set_handle_robots(False)

# Follows refresh 0 but not hangs on refresh > 0
br.set_handle_refresh(mechanize._http.HTTPRefreshProcessor(), max_time=1)

# User-Agent (this is cheating, ok?)
br.addheaders = [('User-agent', 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.1) Gecko/2008071615 Fedora/3.0.1-1.fc9 Firefox/3.0.1')]

# The site we will navigate into, handling it's session
br.open('http://gmail.com')

# Select the first (index zero) form
br.select_form(nr=0)

# User credentials
br.form['Email'] = 'captn3m0'
br.form['Passwd'] = 'bot_add_ct Shark'

# Login
br.submit()

# Filter all links to mail messages in the inbox
all_msg_links = [l for l in br.links(url_regex='\?v=c&th=')]
# Select the first 3 messages
for msg_link in all_msg_links[0:3]:
    print msg_link
    # Open each message
    br.follow_link(msg_link)
    html = br.response().read()
    soup = BeautifulSoup(html)
    # Filter html to only show the message content
    msg = str(soup.findAll('div', attrs={'class': 'msg'})[0])
    # Show raw message content
    print msg
    # Convert html to text, easier to read but can fail if you have intl
    # chars
#   print html2text.html2text(msg)
    print
    # Go back to the Inbox
    br.follow_link(text='Inbox')

# Logout
br.follow_link(text='Sign out')
