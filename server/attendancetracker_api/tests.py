from django.test import TestCase
import requests

from attendancetracker_api.models import AttendanceTracker, WebActions


# Create your tests here.


class AttendanceTrackerTestCase(TestCase):
    def setUp(self):
        pass

    @staticmethod
    def test_attendance_tracker():
        student = WebActions('AP21110011061', '11012004', True)
        # Write a code to send a post request to the server with login details in body
        response = requests.post('http://localhost:8000/attendance/', data={'student_id':'AP21110011061', 'student_dob': '11012004', 'first_time_login': 'True'})
        print(response.text)
        return response.text
