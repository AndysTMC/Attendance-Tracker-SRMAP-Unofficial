import glob
import re
import time
import os
from PIL import Image
from selenium.webdriver.chrome.service import Service
from seleniumwire import webdriver
from selenium.webdriver.common.by import By
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText


# Create your models here.

class Counter:
    def __init__(self, max_count):
        self.count = 1
        self.max_count = max_count

    def increment(self):
        self.count += 1

    def get_count(self):
        return self.count

    def is_max_count_reached(self):
        if self.count <= self.max_count:
            self.increment()
            return False
        return True

    def reset(self):
        self.count = 0


class PortalConfig:
    def __init__(self, pu, phu, ue_xpath, pe_xpath, vo_xpath, vee_xpath, lb_xpath, sn_xpath, apn_xpaths, tt_xpath,
                 at_xpath):
        self.portal_url = pu
        self.portal_home_url = phu
        self.username_element_xpath = ue_xpath
        self.password_element_xpath = pe_xpath
        self.verification_object_xpath = vo_xpath
        self.verification_entry_element_xpath = vee_xpath
        self.login_button_xpath = lb_xpath
        self.student_name_xpath = sn_xpath
        self.attendance_page_navigation_xpaths = apn_xpaths
        self.time_table_xpath = tt_xpath
        self.attendance_table_xpath = at_xpath


# Portal configurations

# SRM University, AP, Amaravati
SRMapPortalConfig = PortalConfig(
    # Link to the parent srmap portal --> https://parent.srmap.edu.in
    pu='https://parent.srmap.edu.in/srmapparentcorner/LoginPage',
    # Link to the parent srmap portal home page --> https://parent.srmap.edu.in/srmapparentcorner/HRDSystem
    phu='https://parent.srmap.edu.in/srmapparentcorner/HRDSystem',
    # The xpath of the username element in the login page
    ue_xpath='//*[@id="UserName"]',
    # The xpath of the password element in the login page
    pe_xpath='//*[@id="AuthKey"]',
    # The xpath of the captcha image in the login page
    vo_xpath='//*[@id="frmSL"]/div[3]/img',
    # The xpath of the captcha text entry element in the login page
    vee_xpath='//*[@id="ccode"]',
    # The xpath of the login button in the login page
    lb_xpath='//*[@id="frmSL"]/button',
    # The xpath of the student name element in the attendance page
    sn_xpath='/html/body/div/div/div[1]/div/div[3]/div[2]/h2',
    # The xpath of the attendance page navigation elements in the home page
    # The first element is the xpath of the academic button
    # The second element is the xpath of the attendance button
    apn_xpaths={'academic': '//*[@id="sidebar-menu"]/div/ul/li[1]/a',
                'attendance': '//*[@id="sidebar-menu"]/div/ul/li[1]/ul/li[3]/a'},
    # The xpath of the time table button
    tt_xpath='//*[@id="sidebar-menu"]/div/ul/li[1]/ul/li[2]/a',
    # The id of the attendance table in the attendance page
    at_xpath='//*[@id="tblSubjectWiseAttendance"]',
)


class WebActions:
    def __init__(self, username, password, first_time_login):
        self.driver = None
        self.portal_config = SRMapPortalConfig
        self.login_credentials = {
            'username': username,
            'password': password
        }
        self.first_time_login = first_time_login
        self.max_count = 1

    def create_site_instance(self):
        try:
            target_exe = "chromedriver.exe"
            driver_path = glob.glob(os.path.join(os.getcwd() + '\\lib', '**', target_exe), recursive=True)[0]
            chrome_options = webdriver.ChromeOptions()
            chrome_options.add_argument("--no-sandbox")
            chrome_options.add_argument(
                """user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) 
                Chrome/88.0.4324.150 Safari/537.36""")
            chrome_options.add_argument("--user-data-dir=/path/to/user-profile-directory")
            chrome_options.add_argument("--headless")
            chrome_options.add_argument('window-size=1920x1080')
            service = Service(executable_path=driver_path)
            self.driver = webdriver.Chrome(service=service, options=chrome_options)
            self.driver.scopes = ['.*']
            self.driver.request_interceptor = lambda r: r
        except Exception as e:
            print(e)
            raise Exception("Failed to create site instance")

    def quit(self):
        self.driver.quit()

    def login(self):
        counter = Counter(max_count=self.max_count)
        while True:
            try:
                # keep track of awaken chrome instances with pid
                print("Log: Attempting to login to parent portal")
                self.driver.get(self.portal_config.portal_url)
                time.sleep(2)
                username_element = self.return_element_if_present("username", self.portal_config.username_element_xpath)
                username_element.send_keys(self.login_credentials['username'])
                password_element = self.return_element_if_present("password", self.portal_config.password_element_xpath)
                password_element.send_keys(self.login_credentials['password'])
                captcha_image = self.get_captcha_image()
                captcha_text = Utils.process_captcha_image(captcha_image)
                os.remove('captcha.png')
                print("Log: Successfully processed captcha image")
                self.insert_captcha(captcha_text)
                print("Log: Successfully logged in to parent portal")
                break
            except Exception as e:
                print(str(e))
                print(counter.count)
                if counter.is_max_count_reached():
                    raise e
                continue
            raise Exception("Log: Invalid credentials")

    def return_element_if_present(self, element_name, element_xpath):
        try:
            element = self.driver.find_element(By.XPATH, element_xpath)
            print("Log: Found " + element_name + " element")
        except Exception:
            raise Exception("Log: Failed in finding " + element_name + " element")
        if element is None:
            raise Exception("Log: The returned is None")
        else:
            while element.is_displayed() is False or element.is_enabled() is False:
                time.sleep(1)
        return element

    def navigate_to_attendance_page(self):
        navigation_elements = self.portal_config.attendance_page_navigation_xpaths
        try:
            for (element_name, element_path) in navigation_elements.items():
                nav_element = self.return_element_if_present(element_name, element_path)
                nav_element.click()
        except Exception:
            raise Exception("Log: Failed in navigating to attendance page")

    def get_student_name(self):
        try:
            student_name = self.return_element_if_present("student name", self.portal_config.student_name_xpath)
        except Exception:
            raise Exception("Log: Failed in getting student name")
        return student_name.text

    def re_login_if_not_logged_in(self):
        counter = Counter(max_count=self.max_count)
        Utils.kill_all_chrome_processes()
        while True:
            try:
                self.create_site_instance()
                self.login()
                if self.driver.current_url == self.portal_config.portal_home_url:
                    break
                if counter.is_max_count_reached():
                    raise Exception("Log: Failed in getting attendance data")
                self.quit()
            except Exception as e:
                raise e

    def get_attendance(self, student_name=""):
        try:
            self.navigate_to_attendance_page()
            time.sleep(2)
            table = self.return_element_if_present("attendance table", self.portal_config.attendance_table_xpath)
            try:
                rows = table.find_elements(By.TAG_NAME, 'tr')
                tracker = AttendanceTracker(self.login_credentials['username'],
                                            student_name)
                length = len(rows[2].find_elements(By.TAG_NAME, 'td'))
                for row in rows[2:]:
                    if row.find_elements(By.TAG_NAME, 'td') is None or len(
                            row.find_elements(By.TAG_NAME, 'td')) != length:
                        break
                    cells = row.find_elements(By.TAG_NAME, 'td')
                    subject_code = cells[0].text.strip()
                    total_hours = int(cells[2].text)
                    present_hours = int(cells[3].text)
                    not_entered_hours = int(cells[5].text)
                    percentage = float(cells[9].text)
                    tracker.add_attendance(subject_code, total_hours, present_hours,
                                           not_entered_hours, percentage)
                    # print the data in a formatted way
                    # print("Subject Code: " + subject_code + " Total Hours: " + str(total_hours) + " Present Hours: " + str(present_hours) + " Not Entered Hours: " + str(not_entered_hours))
                print("Log: Successfully fetched attendance data")
            except Exception:
                raise Exception("Log: Couldn't find requested data in attendance table")
            return tracker
        except Exception as e:
            raise e

    def get_timetable(self):
        try:
            timetable_button = self.return_element_if_present("timetable button",
                                                              self.portal_config.time_table_xpath)
            timetable_button.click()
            time.sleep(2)
            tables = self.driver.find_elements(By.TAG_NAME, 'table')
            schedule_table = tables[0]
            subject_table = tables[1]
            try:
                rows = schedule_table.find_elements(By.TAG_NAME, 'tr')
                schedule_days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                time_intervals = rows[1].find_elements(By.TAG_NAME, 'td')
                schedule_timings = [time_interval.text for time_interval in time_intervals[1:]]
                schedule_subjects = []
                for row in rows[2:]:
                    cells = row.find_elements(By.TAG_NAME, 'td')
                    subjects = []
                    for cell in cells[1:]:
                        match = re.search(r'[A-Z]{2,}\s\d{3}[A-Z]?', cell.text.strip())
                        if match:
                            subjects.append(match.group(0))
                        else:
                            subjects.append("NA")
                    schedule_subjects.append(subjects)
                print("Log: Successfully fetched timetable data")
            except Exception:
                raise Exception("Log: Couldn't find requested data in timetable table")
            try:
                rows = subject_table.find_elements(By.TAG_NAME, 'tr')
                student_subjects = dict(())
                for row in rows[1:]:
                    cells = row.find_elements(By.TAG_NAME, 'td')
                    subject_code = cells[0].text.strip()
                    subject_name = cells[1].text.strip()
                    ltpc = cells[2].text.strip()
                    teacher_name = cells[3].text.strip()
                    matches = re.findall(r'[A-Z]\s*\d{3}(?:\s*\(lab\))?', cells[4].text.strip())
                    if len(matches) > 0:
                        if len(matches) == 1:
                            classrooms = matches[0]
                        else:
                            classrooms = "(" + matches[0]
                            for i in range(1, len(matches)):
                                classrooms += " | " + matches[i]
                            classrooms += ")"
                    else:
                        classrooms = "NA"
                    student_subjects[subject_code] = [subject_name, ltpc, teacher_name, classrooms]
                    # print the data in a formatted way
                    # print(subject_code + " " + subject_name + " " + ltpc + " " + teacher_name + " " + classroom_name)
            except Exception:
                raise Exception("Log: Couldn't find requested data in subject table")
        except Exception as e:
            raise e
        return {"sem_period": ["2024-01-17", "2024-05-15"],
                "time_schedule": {"schedule_days": schedule_days, 'schedule_timings': schedule_timings,
                                  'schedule_subjects': schedule_subjects}, "subjects_info": student_subjects}

    def get_attendance_without_timetable(self):
        try:
            self.re_login_if_not_logged_in()
            attendance_tracker = self.get_attendance()
            return [None, attendance_tracker, None]
        except Exception as e:
            raise e

    def get_attendance_with_timetable(self):
        try:
            self.re_login_if_not_logged_in()
            student_name = self.get_student_name()
            attendance_tracker = self.get_attendance(student_name)
            timetable = self.get_timetable()
            return [student_name, attendance_tracker, timetable]
        except Exception as e:
            raise e

    def get_data(self):
        if self.first_time_login:
            return self.get_attendance_with_timetable()
        else:
            return self.get_attendance_without_timetable()

    def insert_captcha(self, captcha_text):
        counter = Counter(max_count=self.max_count)
        while True:
            try:
                captcha_element = self.return_element_if_present("captcha entry",
                                                                 self.portal_config.verification_entry_element_xpath)
                captcha_element.clear()
                try:
                    captcha_element.send_keys(captcha_text)
                except Exception:
                    raise Exception("Log: Failed to enter captcha")
                break
            except Exception as e:
                if counter.is_max_count_reached():
                    raise e
                print("Log: Failed to enter captcha. Retrying...")
                time.sleep(1)

    def get_captcha_image(self):
        counter = Counter(max_count=self.max_count)
        try:
            while True:
                try:
                    captcha_image = self.return_element_if_present("captcha image",
                                                                   self.portal_config.verification_object_xpath)
                    if captcha_image:
                        break
                except Exception:
                    if counter.is_max_count_reached():
                        raise Exception("Log: Failed to get captcha image")
                    else:
                        time.sleep(1)
            captcha_request = None
            for request in self.driver.requests:
                if request.url == captcha_image.get_attribute('src'):
                    captcha_request = request
                    break
            if captcha_request:
                captcha_image_data = captcha_request.response.body
                with open('captcha.png', 'wb') as file:
                    file.write(captcha_image_data)
            else:
                raise Exception("Log: Failed to found captcha image element src in request urls")
        except Exception as e:
            raise e
        return Image.open('captcha.png')


class AttendanceTracker:
    def __init__(self, student_id, student_name):
        self.attendances = {}
        self.student_id = student_id
        self.student_name = student_name

    def add_attendance(self, subject_code, total_hours, present_hours,
                       not_entered_hours, attendance_percentage):
        try:
            self.attendances[subject_code] = [present_hours, total_hours, not_entered_hours, attendance_percentage]
        except Exception:
            raise Exception("Log: Failed to calculate attendance percentage for subject: " + subject_code)

    def to_dictionary(self):
        return {"name": self.student_name, "attendance": self.attendances}

    def send_email(self, email):
        try:
            body = "<html><body>"
            body += "<h3> Hey, " + self.student_name + " ( " + self.student_id + " ) " + "<h3>"
            body += "<h3> Your attendance status is as follows: </h3>"
            body += "<table border=\"1\" cellspacing=\"0\" cellpadding=\"5\">"
            body += '<tr><th>Subject Code</th><th>Subject Description</th><th>Total Hours</th><th>Present Hours</th><th>Attendance Percentage</th></tr>'
            for subject_code, attendance_data in self.attendances.items():
                subject_description = attendance_data['subject_description']
                total_hours = attendance_data['total_hours']
                present_hours = attendance_data['present_hours']
                not_entered_hours = attendance_data['not_entered_hours']
                attendance_percentage = attendance_data['attendance_percentage']
                if not_entered_hours == 0:
                    body += '<tr><td>' + subject_code + '</td><td>' + subject_description + '</td><td>' + str(
                        total_hours) + '</td><td>' + str(present_hours) + '</td><td>' + "{:.2f}".format(
                        attendance_percentage) + '</td></tr>'
                else:
                    body += '<tr><td bgcolor="#FFFF00">' + subject_code + '</td><td bgcolor="#FFFF00">' + subject_description + '</td><td bgcolor="#FFFF00">' + str(
                        total_hours) + '</td><td bgcolor="#FFFF00">' + str(
                        present_hours) + '</td><td bgcolor="#FFFF00">' + "{:.2f}".format(
                        attendance_percentage) + '</td></tr>'
            body += '</table>'
            below_threshold = False
            for subject_code, attendance_data in self.attendances.items():
                subject_description = attendance_data['subject_description']
                attendance_percentage = attendance_data['attendance_percentage']
                if attendance_percentage < 75:
                    below_threshold = True
                    remaining_hours = self.calculate_remaining_hours(subject_code)
                    data = f"You have to attend {remaining_hours} more classes for {subject_code} - {subject_description} to get sufficient attendance."
                    body += '<h4>' + data + '</h4>'
            if not below_threshold:
                data = "All the attendances are in safe."
                body += '<h4>' + data + '</h4>'
            body += '<h4 style="color:red">Note: The subjects of yellow colored background are subjected to change later on as the attendance for some date is not entered yet.</h4>'
            body += '<h4>Regards,<br>Attendance Tracker</h4>'
            body += "</body></html>"
            print("Log: Sending email to " + self.student_name + " ( " + self.student_id + " ) " + " at " + email)
            Utils.forward_to_mail(self.student_name, email, body)
        except Exception as e:
            raise e

    def display_attendance_status(self):
        print("Student Name: {}".format(self.student_name))
        print("Student ID  : {}".format(self.student_id))
        print(
            "Subject Code\tSubject Description\t\t\t\t\t\t\t\t\t  Total Hours  \t\tPresent Hours \tAttendance Percentage")
        for subject_code, attendance_data in self.attendances.items():
            subject_description = attendance_data['subject_description']
            total_hours = attendance_data['total_hours']
            present_hours = attendance_data['present_hours']
            attendance_percentage = attendance_data['attendance_percentage']
            print("{:<12}\t{:<40}\t{:>12}\t{:>14}\t{:>18.2f}".format(subject_code, subject_description, total_hours,
                                                                     present_hours, attendance_percentage))
        below_threshold = False
        for subject_code, attendance_data in self.attendances.items():
            subject_description = attendance_data['subject_description']
            attendance_percentage = attendance_data['attendance_percentage']
            if attendance_percentage < 75:
                below_threshold = True
                remaining_hours = self.calculate_remaining_hours(subject_code)
                data = f"You have to attend {remaining_hours} more classes for {subject_code} - {subject_description} to get sufficient attendance."
                print("\n" + data)
        if not below_threshold:
            data = "All the attendances are in safe."
            print("\n" + data)

    def calculate_remaining_hours(self, subject_code):
        return int((75 * self.attendances[subject_code]['total_hours'] - 100 * self.attendances[subject_code][
            'present_hours']) / 25)


class Utils:
    @staticmethod
    def kill_all_chrome_processes():
        # for proc in psutil.process_iter(['name']):
        #     if proc.name() == "chrome.exe":
        #         proc.kill()
        # print("Log: killed_all_chrome_processes")
        pass

    @staticmethod
    def process_captcha_image(captcha_image):
        import pytesseract
        import os
        try:
            target_exe = "tesseract.exe"
            tesseract_path = glob.glob(os.path.join(os.getcwd() + '\\lib', '**', target_exe), recursive=True)[0]
            pytesseract.pytesseract.tesseract_cmd = tesseract_path
            captcha_text = pytesseract.image_to_string(captcha_image) + ""
            if captcha_text == "":
                raise Exception("Failed to process captcha image")
            else:
                return captcha_text.upper()
        except Exception as e:
            raise e

    @staticmethod
    def forward_to_mail(recipient_name, recipient_mail, body):
        """

        """
        try:
            with open('sender_info.txt', 'r') as sender_file:
                sender_email, sender_password = sender_file.read().splitlines()

            subject = "Here's your attendance report by Attendance Tracker"
            message = MIMEMultipart()
            message["From"] = sender_email
            message["To"] = recipient_mail
            message["Subject"] = subject
            message.attach(MIMEText(body, "html"))

            with smtplib.SMTP("smtp.office365.com", 587) as server:
                server.starttls()
                server.login(sender_email, sender_password)
                server.send_message(message)

            print("Log: Successfully sent email to " + recipient_name + " at " + recipient_mail)
            return 200
        except Exception:
            raise Exception("Failed to forward mail")
