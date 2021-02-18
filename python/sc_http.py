import requests as req
import urllib3.util.url as url


class SCHTTP:

    def __init__(self):
        self.base_url = 'https://crm.singlecare.com/'

    def get(self, params, headers):
        try:
            uri = url.Url(self.base_url, params, headers)
            req.get(url=uri, params=params, header=headers)
        except req.exceptions.HTTPError:
            print('GET Error')

    def post(self, params, headers):
        try:
            uri = url.Url(self.base_url, params, headers)
            req.post(url=uri, params=params, header=headers)
        except req.exceptions.HTTPError:
            print('POST Error')
