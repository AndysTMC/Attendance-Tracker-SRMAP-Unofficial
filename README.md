**<h1><img src="https://github.com/AndysTMC/Attendance-Tracker-SRMAP/blob/75cb3a0cbe25c4a8ea972830f38d5fa2c5566346/app/android/app/src/main/res/mipmap-hdpi/ic_launcher_round.png" style="width:38px; height:38px;translate: -5px 7px;">Attendance Tracker</h1>**
<p>https://github.com/AndysTMC/AttendanceTracker</p>
<h2>Description</h2>
</p>The Attendance Tracker is a specialized tool created for educational purposes, specifically tailored to streamline attendance monitoring for students. It's designed for those with knowledge of GitHub repository usage and offers a unique opportunity for student developers to gain practical experience with a range of technologies.
<h2>Target Audience</h2>
This project is intended for:<br><br>
<b>(Student) Developers</b>: Those looking to enhance their skills by working with real-world technologies, including Django, Selenium, Tesseract OCR, and Flutter.<br>
<b>Students</b>: Instructors seeking an effective way to manage attendance in their courses.<br><br>
Overall, this project demonstrates using automation and optical character recognition to simplify attendance tracking. It's a great learning project for student developers.
<h2>Prerequisites</h2>
Before you can get started with the Attendance Tracker project, there are several prerequisites and dependencies you'll need to have in place. Please ensure that you have the following tools and software installed:<br><br>
<b>Python</b>: The project relies on Python for various components.
<ul>
  <li>Make sure you have Python (version 11) installed on your system.</li>
  <li>You can download it from the <a href="https://www.python.org/downloads/">official Python website.</a></li>
</ul>
<b>Git</b>: To use or work with the project's source code and collaborate with others, make sure you have Git installed. You can download it from the <a href="https://git-scm.com/downloads">official Git website</a>.<br>
<h3>Optional(only for developers):</h3>
<b>Flutter</b>: The mobile application component is built using Flutter, a framework by Google for building natively compiled applications for mobile from a single codebase. Follow the installation guide on the <a href="https://docs.flutter.dev/get-started/install">Flutter website</a> to set up Flutter on your development machine.<br>
<b>Android Studio</b>: Android Studio is essential for Flutter development, as it provides the Android Emulator and other tools. You can download and install Android Studio from the <a href="https://developer.android.com/studio">official Android Studio website</a>.

<h2>Getting Started (Installation)</h2>
Follow these steps to install and set up the Attendance Tracker project on your local machine: (Ensure that the prerequisites are fulfilled)
<ul>
  <li><b>Clone the Repository</b>: Start by cloning the project's repository to your local machine. Open your terminal or command prompt and execute the following command, replacing <repository_url> with the actual URL of your project's repository:<br><code>git clone https://github.com/AndysTMC/AttendanceTracker.git</code></li>
  <li><b>Navigate to the Project Directory</b>: Change your working directory to the project's root folder:<br><code>cd AttendanceTracker</code></li>
  <li><strong>Installing the Tesseract Library</strong>: Download and install the <a href="www.google.com">Tesseract Executable</a>. During installation, specify the path to the <em>path/to/Attendance-Tracker-SRMAP/server/lib/</em> folder.</li>
  <li><b>Install Python Packages</b>: Navigate to the server folder of the project and install the required Python packages by running 'install_requirements.bat' file</li>
  <li><b>Install Flutter Dependencies and Build Application(for developers)</b>: Navigate to the app folder:<br><code>cd Path/to/attendance_tracker/app</code><br>Install the flutter dependencies<br><code>flutter pub get</code><br>(If you're building application for android) Connect your mobile device to your PC and enable USB Debugging. Once connected, you can build the flutter application in two ways <ul><li>Click the 'RUN' button in your integrated development environment (IDE)</li><li>Alternatively, use the command:</li><code>flutter run</code></ul>
<br>NOTE: It is advisable to prioritize either the Android or Windows platform at this time, as the application has not undergone testing on alternative platforms.</li>
  <li><b>Install Android Platform Application(for students)</b>: Install the <a href="www.google.com">Attendance Tracker Android Application</a></li>
  <li><b>Install Widnows Platform Application(for students)</b>: Install the <a href="www.google.com">Attendance Tracker Windows Application</a></li>
</ul>
<h2>Usage</h2>
Follow these instructions to effectively use the Attendance Tracker:
<h3>Server</h3>
<ul><li>Click on the 'runserver.bat' file in located at 'Path/to/AttendanceTracker/server/' of the cloned repository on your machine to run the server.</li>
  <br>NOTE: You cannot update or get into the flutter application unless the server is turned on
</ul>
<h3>Flutter Application</h3>
<h4>On Android</h4>
<ul>
  <li>Open the application</li>
  <li>Enter required details</li>
  <li>Click on 'GET IN' to scan the QR code (generated on your machine when server was started)</li>
  <li>That's it. Enjoy the application.</li>
  <li>Scan the QR code by clicking on the QR scanner icon inside the application whenever needed to update your attendance</li>
</ul>
<h4>On Windows</h4>
<ul>
  <li>Open the application</li>
  <li>Enter required details</li>
  <li>Click on 'GET IN' to enter into the application</li>
  <li>That's it. Enjoy the application.</li>
  <li>Click on the Refresh icon inside the application whenever needed to update your attendance</li>
</ul>
