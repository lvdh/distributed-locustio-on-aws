# coding=utf-8

# Locustfile for http://blazedemo.com/

from locust import HttpLocust, TaskSet, TaskSequence, seq_task, task, between
from bs4 import BeautifulSoup
import logging
import sys

# Log to stdout during Locust run
logger = logging.getLogger("locust")
logger.setLevel(logging.INFO)


class CustomTaskSequence(TaskSequence):
    """ TaskSequence with customized request handling (eg. login, CSRF, ...)

    For example:
    * Automated user login before running tasks
    * CSRF handling
    * Custom HTTP request logic

    """

    def on_start(self):
        """ Called by every Locust slave before tasks are scheduled """

        # For Example:
        # Each simulated user should log in before running tasks
        # UserLogin.login()
        # self.login()

    def get_csrf(self, url):
        """ Retrieve a CSRF token for use with POST requests """

        # Get page HTML
        response = self.client.get(
            name="(Locust) Get CSRF token",
            url=url
        )

        soup = BeautifulSoup(response.content, 'html.parser')

        # Parse CSRF token from page HTML
        csrf_param = soup.find(
            'meta',
            attrs={'name': 'csrf-param'}
        ).get("content")
        csrf_token = soup.find(
            'meta',
            attrs={'name': 'csrf-token'}
        ).get("content")

        return {
            "param": csrf_param,
            "token": csrf_token
        }

    def get(self, task_url, task_id, task_description):
        """ Send a GET request to the web application """

        response = self.client.get(
            name="#{}: {}".format(task_id, task_description),
            url="{}".format(task_url),
        )

        return response

    def post(self, task_url, task_id, task_description, task_data_params):
        """ Send a POST request to the web application """

        # With CSRF:
        # csrf_data = self.get_csrf(task_url)
        # logger.debug(
        #     "Running '{}': ".format(sys._getframe().f_code.co_name) +
        #     "CSRF: {}".format(csrf_data)
        # )

        response = self.client.post(
            name="#{}: {}".format(task_id, task_description),
            url=task_url,
            # Without CSRF:
            data=task_data_params,
            # With CSRF:
            # headers={
            #    csrf_data['param']: csrf_data['token']
            # },
            # data={
            #    csrf_data['param']: csrf_data['token'],
            #    task_data_params
            # },
        )

        return response


class UserRegistration(CustomTaskSequence):

    @seq_task(1000)
    @task(1)
    def task_1000(self):
        task_url = "/"  # NOQA
        task_id = "1000"  # NOQA
        task_description = "(UserRegistration) Visit /"  # NOQA
        task_data_params = "None"  # NOQA

        # Logging
        logger.info(
            "Run {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            )
        )

        logger.debug(
            "locust.client: {}".format(self.locust.client.__dict__)
        )

        # HTTP request logic
        response = self.get(task_url, task_id, task_description)

        # Logging
        logger.debug(
            "Response for {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            ) +
            "HTTP {} ({} {}), ".format(
                response.status_code,
                response.request,
                response.url
            ) +
            "Headers: {} ,".format(response.headers) +
            "Cookies: {}".format(response.cookies)
        )

    @seq_task(1001)
    @task(1)
    def task_1001(self):
        task_url = "/home"  # NOQA
        task_id = "1001"  # NOQA
        task_description = "(UserRegistration) Click 'home'"  # NOQA
        task_data_params = "None"  # NOQA

        # Logging
        logger.info(
            "Run {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            )
        )

        logger.debug(
            "locust.client: {}".format(self.locust.client.__dict__)
        )

        # HTTP request logic
        response = self.get(task_url, task_id, task_description)

        # Logging
        logger.debug(
            "Response for {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            ) +
            "HTTP {} ({} {}), ".format(
                response.status_code,
                response.request,
                response.url
            ) +
            "Headers: {} ,".format(response.headers) +
            "Cookies: {}".format(response.cookies)
        )

    @seq_task(1002)
    @task(1)
    def task_1002(self):
        task_url = "/register"  # NOQA
        task_id = "1002"  # NOQA
        task_description = "(UserRegistration) Click 'Register'"  # NOQA
        task_data_params = "None"  # NOQA

        # Logging
        logger.info(
            "Run {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            )
        )

        logger.debug(
            "locust.client: {}".format(self.locust.client.__dict__)
        )

        # HTTP request logic
        response = self.get(task_url, task_id, task_description)

        # Logging
        logger.debug(
            "Response for {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            ) +
            "HTTP {} ({} {}), ".format(
                response.status_code,
                response.request,
                response.url
            ) +
            "Headers: {} ,".format(response.headers) +
            "Cookies: {}".format(response.cookies)
        )

    @seq_task(1003)
    @task(1)
    def task_1003(self):
        task_url = "/register"  # NOQA
        task_id = "1003"  # NOQA
        task_description = "(UserRegistration) Register as user test@example.org"  # NOQA
        task_data_params = "name=Test&company=Test&email=test%40example.org&password=test&password_confirmation=test"  # NOQA

        # Logging
        logger.info(
            "Run {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            )
        )

        logger.debug(
            "locust.client: {}".format(self.locust.client.__dict__)
        )

        # HTTP request logic
        response = self.post(task_url, task_id, task_description, task_data_params)

        # Logging
        logger.debug(
            "Response for {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            ) +
            "HTTP {} ({} {}), ".format(
                response.status_code,
                response.request,
                response.url
            ) +
            "Headers: {} ,".format(response.headers) +
            "Cookies: {}".format(response.cookies)
        )


class UserLogin(CustomTaskSequence):

    @seq_task(1100)
    @task(1)
    def task_1100(self):
        task_url = "/"  # NOQA
        task_id = "1100"  # NOQA
        task_description = "(UserLogin) Visit /"  # NOQA
        task_data_params = "None"  # NOQA

        # Logging
        logger.info(
            "Run {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            )
        )

        logger.debug(
            "locust.client: {}".format(self.locust.client.__dict__)
        )

        # HTTP request logic
        response = self.get(task_url, task_id, task_description)

        # Logging
        logger.debug(
            "Response for {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            ) +
            "HTTP {} ({} {}), ".format(
                response.status_code,
                response.request,
                response.url
            ) +
            "Headers: {} ,".format(response.headers) +
            "Cookies: {}".format(response.cookies)
        )

    @seq_task(1101)
    @task(1)
    def task_1101(self):
        task_url = "/"  # NOQA
        task_id = "1101"  # NOQA
        task_description = "(UserLogin) Click 'home'"  # NOQA
        task_data_params = "None"  # NOQA

        # Logging
        logger.info(
            "Run {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            )
        )

        logger.debug(
            "locust.client: {}".format(self.locust.client.__dict__)
        )

        # HTTP request logic
        response = self.get(task_url, task_id, task_description)

        # Logging
        logger.debug(
            "Response for {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            ) +
            "HTTP {} ({} {}), ".format(
                response.status_code,
                response.request,
                response.url
            ) +
            "Headers: {} ,".format(response.headers) +
            "Cookies: {}".format(response.cookies)
        )

    @seq_task(1102)
    @task(1)
    def task_1102(self):
        task_url = "/"  # NOQA
        task_id = "1102"  # NOQA
        task_description = "(UserLogin) Click 'Login'"  # NOQA
        task_data_params = "None"  # NOQA

        # Logging
        logger.info(
            "Run {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            )
        )

        logger.debug(
            "locust.client: {}".format(self.locust.client.__dict__)
        )

        # HTTP request logic
        response = self.get(task_url, task_id, task_description)

        # Logging
        logger.debug(
            "Response for {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            ) +
            "HTTP {} ({} {}), ".format(
                response.status_code,
                response.request,
                response.url
            ) +
            "Headers: {} ,".format(response.headers) +
            "Cookies: {}".format(response.cookies)
        )

    @seq_task(1103)
    @task(1)
    def task_1103(self):
        task_url = "/login"  # NOQA
        task_id = "1103"  # NOQA
        task_description = "(UserLogin) Log in as user test@example.org"  # NOQA
        task_data_params = "email=test%40example.org&password=test"  # NOQA

        # Logging
        logger.info(
            "Run {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            )
        )

        logger.debug(
            "locust.client: {}".format(self.locust.client.__dict__)
        )

        # HTTP request logic
        response = self.post(task_url, task_id, task_description, task_data_params)

        # Logging
        logger.debug(
            "Response for {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            ) +
            "HTTP {} ({} {}), ".format(
                response.status_code,
                response.request,
                response.url
            ) +
            "Headers: {} ,".format(response.headers) +
            "Cookies: {}".format(response.cookies)
        )


class UserPasswordReset(CustomTaskSequence):

    @seq_task(1200)
    @task(1)
    def task_1200(self):
        task_url = "/"  # NOQA
        task_id = "1200"  # NOQA
        task_description = "(UserPasswordReset) Visit /"  # NOQA
        task_data_params = "None"  # NOQA

        # Logging
        logger.info(
            "Run {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            )
        )

        logger.debug(
            "locust.client: {}".format(self.locust.client.__dict__)
        )

        # HTTP request logic
        response = self.get(task_url, task_id, task_description)

        # Logging
        logger.debug(
            "Response for {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            ) +
            "HTTP {} ({} {}), ".format(
                response.status_code,
                response.request,
                response.url
            ) +
            "Headers: {} ,".format(response.headers) +
            "Cookies: {}".format(response.cookies)
        )

    @seq_task(1201)
    @task(1)
    def task_1201(self):
        task_url = "/home"  # NOQA
        task_id = "1201"  # NOQA
        task_description = "(UserPasswordReset) Click 'home'"  # NOQA
        task_data_params = "None"  # NOQA

        # Logging
        logger.info(
            "Run {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            )
        )

        logger.debug(
            "locust.client: {}".format(self.locust.client.__dict__)
        )

        # HTTP request logic
        response = self.get(task_url, task_id, task_description)

        # Logging
        logger.debug(
            "Response for {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            ) +
            "HTTP {} ({} {}), ".format(
                response.status_code,
                response.request,
                response.url
            ) +
            "Headers: {} ,".format(response.headers) +
            "Cookies: {}".format(response.cookies)
        )

    @seq_task(1202)
    @task(1)
    def task_1202(self):
        task_url = "/password/reset"  # NOQA
        task_id = "1202"  # NOQA
        task_description = "(UserPasswordReset) Click 'Forgot Your Password?'"  # NOQA
        task_data_params = "None"  # NOQA

        # Logging
        logger.info(
            "Run {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            )
        )

        logger.debug(
            "locust.client: {}".format(self.locust.client.__dict__)
        )

        # HTTP request logic
        response = self.get(task_url, task_id, task_description)

        # Logging
        logger.debug(
            "Response for {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            ) +
            "HTTP {} ({} {}), ".format(
                response.status_code,
                response.request,
                response.url
            ) +
            "Headers: {} ,".format(response.headers) +
            "Cookies: {}".format(response.cookies)
        )

    @seq_task(1203)
    @task(1)
    def task_1203(self):
        task_url = "/password/reset"  # NOQA
        task_id = "1203"  # NOQA
        task_description = "(UserPasswordReset) Request new password"  # NOQA
        task_data_params = "email=test%40example.org"  # NOQA

        # Logging
        logger.info(
            "Run {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            )
        )

        logger.debug(
            "locust.client: {}".format(self.locust.client.__dict__)
        )

        # HTTP request logic
        response = self.post(task_url, task_id, task_description, task_data_params)

        # Logging
        logger.debug(
            "Response for {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            ) +
            "HTTP {} ({} {}), ".format(
                response.status_code,
                response.request,
                response.url
            ) +
            "Headers: {} ,".format(response.headers) +
            "Cookies: {}".format(response.cookies)
        )


class TravelTheWorld(CustomTaskSequence):

    @seq_task(1300)
    @task(1)
    def task_1300(self):
        task_url = "/"  # NOQA
        task_id = "1300"  # NOQA
        task_description = "(TravelTheWorld) Visit /"  # NOQA
        task_data_params = "None"  # NOQA

        # Logging
        logger.info(
            "Run {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            )
        )

        logger.debug(
            "locust.client: {}".format(self.locust.client.__dict__)
        )

        # HTTP request logic
        response = self.get(task_url, task_id, task_description)

        # Logging
        logger.debug(
            "Response for {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            ) +
            "HTTP {} ({} {}), ".format(
                response.status_code,
                response.request,
                response.url
            ) +
            "Headers: {} ,".format(response.headers) +
            "Cookies: {}".format(response.cookies)
        )

    @seq_task(1301)
    @task(1)
    def task_1301(self):
        task_url = "/index.php"  # NOQA
        task_id = "1301"  # NOQA
        task_description = "(TravelTheWorld) Click 'Travel The World'"  # NOQA
        task_data_params = "None"  # NOQA

        # Logging
        logger.info(
            "Run {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            )
        )

        logger.debug(
            "locust.client: {}".format(self.locust.client.__dict__)
        )

        # HTTP request logic
        response = self.get(task_url, task_id, task_description)

        # Logging
        logger.debug(
            "Response for {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            ) +
            "HTTP {} ({} {}), ".format(
                response.status_code,
                response.request,
                response.url
            ) +
            "Headers: {} ,".format(response.headers) +
            "Cookies: {}".format(response.cookies)
        )


class DestinationOfTheWeek(CustomTaskSequence):

    @seq_task(1400)
    @task(1)
    def task_1400(self):
        task_url = "/"  # NOQA
        task_id = "1400"  # NOQA
        task_description = "(DestinationOfTheWeek) Visit /"  # NOQA
        task_data_params = "None"  # NOQA

        # Logging
        logger.info(
            "Run {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            )
        )

        logger.debug(
            "locust.client: {}".format(self.locust.client.__dict__)
        )

        # HTTP request logic
        response = self.get(task_url, task_id, task_description)

        # Logging
        logger.debug(
            "Response for {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            ) +
            "HTTP {} ({} {}), ".format(
                response.status_code,
                response.request,
                response.url
            ) +
            "Headers: {} ,".format(response.headers) +
            "Cookies: {}".format(response.cookies)
        )

    @seq_task(1401)
    @task(1)
    def task_1401(self):
        task_url = "/vacation.html"  # NOQA
        task_id = "1401"  # NOQA
        task_description = "(DestinationOfTheWeek) Click 'destination of the week!'"  # NOQA
        task_data_params = "None"  # NOQA

        # Logging
        logger.info(
            "Run {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            )
        )

        logger.debug(
            "locust.client: {}".format(self.locust.client.__dict__)
        )

        # HTTP request logic
        response = self.get(task_url, task_id, task_description)

        # Logging
        logger.debug(
            "Response for {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            ) +
            "HTTP {} ({} {}), ".format(
                response.status_code,
                response.request,
                response.url
            ) +
            "Headers: {} ,".format(response.headers) +
            "Cookies: {}".format(response.cookies)
        )


class BookFlight(CustomTaskSequence):

    @seq_task(1500)
    @task(1)
    def task_1500(self):
        task_url = "/"  # NOQA
        task_id = "1500"  # NOQA
        task_description = "(BookFlight) Visit /"  # NOQA
        task_data_params = "None"  # NOQA

        # Logging
        logger.info(
            "Run {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            )
        )

        logger.debug(
            "locust.client: {}".format(self.locust.client.__dict__)
        )

        # HTTP request logic
        response = self.get(task_url, task_id, task_description)

        # Logging
        logger.debug(
            "Response for {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            ) +
            "HTTP {} ({} {}), ".format(
                response.status_code,
                response.request,
                response.url
            ) +
            "Headers: {} ,".format(response.headers) +
            "Cookies: {}".format(response.cookies)
        )

    @seq_task(1501)
    @task(1)
    def task_1501(self):
        task_url = "/reserve.php"  # NOQA
        task_id = "1501"  # NOQA
        task_description = "(BookFlight) Click 'Find Flights' for BOS to DUB"  # NOQA
        task_data_params = "fromPort=Boston&toPort=Dublin"  # NOQA

        # Logging
        logger.info(
            "Run {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            )
        )

        logger.debug(
            "locust.client: {}".format(self.locust.client.__dict__)
        )

        # HTTP request logic
        response = self.post(task_url, task_id, task_description, task_data_params)

        # Logging
        logger.debug(
            "Response for {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            ) +
            "HTTP {} ({} {}), ".format(
                response.status_code,
                response.request,
                response.url
            ) +
            "Headers: {} ,".format(response.headers) +
            "Cookies: {}".format(response.cookies)
        )

    @seq_task(1502)
    @task(1)
    def task_1502(self):
        task_url = "/purchase.php"  # NOQA
        task_id = "1502"  # NOQA
        task_description = "(BookFlight) Click 'Choose This Flight' for flight nr. 9696"  # NOQA
        task_data_params = "flight=9696&price=200.98&airline=Aer+Lingus&fromPort=Boston&toPort=Dublin"  # NOQA

        # Logging
        logger.info(
            "Run {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            )
        )

        logger.debug(
            "locust.client: {}".format(self.locust.client.__dict__)
        )

        # HTTP request logic
        response = self.post(task_url, task_id, task_description, task_data_params)

        # Logging
        logger.debug(
            "Response for {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            ) +
            "HTTP {} ({} {}), ".format(
                response.status_code,
                response.request,
                response.url
            ) +
            "Headers: {} ,".format(response.headers) +
            "Cookies: {}".format(response.cookies)
        )

    @seq_task(1503)
    @task(1)
    def task_1503(self):
        task_url = "/purchase.php"  # NOQA
        task_id = "1503"  # NOQA
        task_description = "(BookFlight) Click 'Purchase Flight'"  # NOQA
        task_data_params = "inputName=John+Smith&address=123+Main+St.&city=Anytown&state=State&zipCode=12345&cardType=visa&creditCardNumber=0000000000000000&creditCardMonth=11&creditCardYear=2017&nameOnCard=John+Smith"  # NOQA

        # Logging
        logger.info(
            "Run {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            )
        )

        logger.debug(
            "locust.client: {}".format(self.locust.client.__dict__)
        )

        # HTTP request logic
        response = self.post(task_url, task_id, task_description, task_data_params)

        # Logging
        logger.debug(
            "Response for {} '{}' ...".format(
                sys._getframe().f_code.co_name,
                task_description
            ) +
            "HTTP {} ({} {}), ".format(
                response.status_code,
                response.request,
                response.url
            ) +
            "Headers: {} ,".format(response.headers) +
            "Cookies: {}".format(response.cookies)
        )


class UserBehavior(TaskSet):
    """ Define the TaskSequences to run, and their weight """

    tasks = {
        UserRegistration: 100,
        UserLogin: 100,
        UserPasswordReset: 100,
        TravelTheWorld: 100,
        DestinationOfTheWeek: 100,
        BookFlight: 100,
    }


class LoadTest(HttpLocust):
    """ Create a Locust slave based on the UserBehavior task set """
    host = "http://blazedemo.com"
    task_set = UserBehavior
    # Speed up things during development
    wait_time = between(0.500, 1.500)
    # More realistic values for load testing
    #wait_time = between(5000, 15000)
