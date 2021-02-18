import requests as req
import urllib3.util.url as url


class SCAPI:

    def __init__(self):
        self.api_url = 'https://csapi.singlecare.com/services/v1_0/private/CRMService.svc/'

    def post(self, service, params):
        headers = {'Content-Type': 'application/json'}
        try:
            uri = url.Url(self.api_url, service)
            req.post(uri, params, headers)
        except req.exceptions.HTTPError:
            print('HTTP Error')
