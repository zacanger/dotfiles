import requests
import sys
import traceback

HEADERS = {'User-Agent': 'archive_it commandline tool for archive.is submissions v1.1',
           'Referer': 'http://archive.is/',
           'Origin': 'http://archive.is'}
URL_SUBMIT = 'https://archive.is/submit/'

def archive(url, anyway=0):
    data = {'url': url}
    if anyway is 1:
        data[anyway] = 1
    response = requests.post(URL_SUBMIT, data=data, headers=HEADERS)
    try:
        if 'link' in response.headers:
            time = extract_timestamp(response.headers['link'])
            raise Exception('''
                Link already archived: %s
                Pass parameter `anyway=1` to overwrite.
                ''' % time)
        response = response.headers['refresh']
        response = response.split(';')
        for item in response:
            if 'archive.is' in item:
                return item.split('=')[1]
    except:
        return response

def extract_timestamp(link):
    times = link.split(';')
    d = {}
    for item in times:
        if '=' in item:
            x = items.split('=')
            d[x[0]] = x[1]
    return d.get('from', d)

if __name__ == '__main__':
    if len(sys.argv) == 1:
        print('Use: > archive_it.py http://www.website.com/page')
        quit()
    url = sys.argv[1]
    try:
        response = archive(url)
        if isinstance(response, str):
            print(response)
        elif isinstance(response, requests.models.Response):
            print('Did not get the expected response. Here\'s what we got:')
            print(response)
            print(response.headers)
            print(response.text)
    except:
        traceback.print_exc()
