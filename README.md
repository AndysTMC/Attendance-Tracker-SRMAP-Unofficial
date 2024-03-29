**<h1><img src="https://github.com/AndysTMC/Attendance-Tracker-SRMAP/blob/222bb0104c3460f86d30b8ec818fb33ce3fc987f/Source/android/app/src/main/res/mipmap-hdpi/ic_launcher_round.png" style="width:38px; height:38px;translate: -5px 7px;">Attendance Tracker SRMAP Unofficial</h1>**
<p>https://github.com/AndysTMC/Attendance-Tracker-SRMAP</p>
<h2>Description</h2>
</p>The Attendance Tracker is a specialized tool created for educational purposes, specifically tailored to streamline attendance monitoring for students. It's designed for those with knowledge of GitHub repository usage and offers a unique opportunity for student developers to gain practical experience with a range of technologies.
<h2>Target Audience</h2>
This project is intended for:<br><br>
<b>(Student) Developers</b>: Those looking to enhance their skills by working with real-world technologies, including Django, Selenium, Tesseract OCR, and Flutter.<br>
<b>Students</b>: Students seeking an effective way to manage attendance in their courses.<br><br>
Overall, this project demonstrates using automation and optical character recognition to simplify attendance tracking. It's a great learning project for student developers.
<h2>Prerequisites</h2>
Before you can get started with the Attendance Tracker project, there are several prerequisites and dependencies you'll need to have in place. Please ensure that you have the following tools and software installed:<br><br>
<b>Python</b>: The project relies on Python for various components.
<ul>
  <li>Make sure you have Python (version >= 3.10) installed on your system.</li>
  <li>You can download it from the <a href="https://www.python.org/downloads/">official Python website.</a></li>
</ul>
<b>Git</b>: To use or work with the project's source code and collaborate with others, make sure you have Git installed. You can download it from the <a href="https://git-scm.com/downloads">official Git website</a>.<br>
<h3>Optional(only for developers):</h3>
<b>Flutter</b>: The mobile application component is built using Flutter, a framework by Google for building natively compiled applications for mobile from a single codebase. Follow the installation guide on the <a href="https://docs.flutter.dev/get-started/install">Flutter website</a> to set up Flutter on your development machine.<br>
<b>Android Studio</b>: Android Studio is essential for Flutter development, as it provides the Android Emulator and other tools. You can download and install Android Studio from the <a href="https://developer.android.com/studio">official Android Studio website</a>.

<h2>Getting Started (Installation)</h2>

https://github.com/AndysTMC/Attendance-Tracker-SRMAP/assets/93911806/1292a287-5623-49a5-b5a7-42e0ee12c339

Follow these steps to install and set up the Attendance Tracker project on your local machine: (Ensure that the prerequisites are fulfilled)
<ul>
  <li><b>Clone the Repository</b>: Start by cloning the project's repository to your local machine. Open your terminal or command prompt and execute the following command, replacing <repository_url> with the actual URL of your project's repository:<br><br>
    
    git clone https://github.com/AndysTMC/Attendance-Tracker-SRMAP.git
  </li>
  <li><b>Navigate to the Project Directory</b>: Change your working directory to the project's root folder:<br><br>
    
    cd Attendance-Tracker-SRMAP
  </li>
  <li><strong>Installing the Tesseract Library</strong>: Download and install the <a href="https://github.com/AndysTMC/Attendance-Tracker-SRMAP/blob/main/Applications/Android/Attendance%20Tracker.apk">Tesseract Executable</a>. During installation, specify the path to the <code>path/to/Attendance-Tracker-SRMAP/Server/lib/</code> folder.</li>
  <li><b>Install Python Packages</b>: <br>Navigate to the server folder of the project and install the required Python packages by running <em>install_requirements.bat</em> file</li>
  <li><b>Install Flutter Dependencies and Build Application(for developers)</b>:<br><br>
     Navigate to the app folder:<br><br>
    
        cd Path/to/Attendance-Tracker-SRMAP/Source
  Install the flutter dependencies<br>
  
        flutter pub get
  (If you're building application for android) Connect your mobile device to your PC and enable USB Debugging. Once connected, you can build the flutter application in two ways <ul><li>Click the 'RUN' button in your integrated development environment (IDE)</li><li>Alternatively, use the command:</li>
  
    flutter run
  </ul>
<br>NOTE: It is advisable to prioritize either the Android or Windows platform at this time, as the application has not undergone testing on alternative platforms.</li>
  <li><b>Install Android Platform Application(for students)</b>: Install the <a href="https://github.com/AndysTMC/Attendance-Tracker-SRMAP/tree/b2ea074ccf4ed70806a12ee58a8be6ff89779a00/Applications/Android">Attendance Tracker Android Application</a></li>
  <li><b>Install Widnows Platform Application(for students)</b>: Install the <a href="https://github.com/AndysTMC/Attendance-Tracker-SRMAP/blob/1eacdf424c63c2be3150379be0fc88ef83eafca5/Applications/Windows/Attendance%20Tracker.zip">Attendance Tracker Windows Application</a></li>
</ul>
<h2>Usage</h2>
Follow these instructions to effectively use the Attendance Tracker:
<h3>Server</h3>

https://github.com/AndysTMC/Attendance-Tracker-SRMAP/assets/93911806/fc8091b8-24d3-49f6-bcf3-e9d62ba29d61

<ul><li>Click on the <em>runserver.bat</em> file in located at <code>Path/to/Attendance-Tracker-SRMAP/Server/</code> of the cloned repository on your machine to run the server.</li>
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

<img src="https://github.com/AndysTMC/Attendance-Tracker-SRMAP/assets/93911806/38410673-2d70-4eca-8fd5-3d8b52005fb7" width="135" alt="AndroidAuthInterface">
<img src="https://github.com/AndysTMC/Attendance-Tracker-SRMAP/assets/93911806/fd1f3bf2-a685-4a89-977f-37100d916379" width="135" alt="AndroidAttendanceInterface">
<img src="https://github.com/AndysTMC/Attendance-Tracker-SRMAP/assets/93911806/45e3a3af-bbb0-49c6-aac2-d14f5a891e1c" width="135" alt="AndroidDetailsInterface">
<img src="https://github.com/AndysTMC/Attendance-Tracker-SRMAP/assets/93911806/ef16ac60-936f-4bee-a010-adf96a799c21" width="135" alt="AndroidScheduleInterface1">
<img src="https://github.com/AndysTMC/Attendance-Tracker-SRMAP/assets/93911806/75e56727-02f0-4d11-9a98-2d873a40a13b" width="135" alt="AndroidScheduleInterface2">
<img src="https://github.com/AndysTMC/Attendance-Tracker-SRMAP/assets/93911806/c9eff63f-c124-4bd3-b883-0893d21c4254" width="135" alt="AndroidScheduleInterface3">

<h4>On Windows</h4>
<ul>
  <li>Open the application</li>
  <li>Enter required details</li>
  <li>Click on 'GET IN' to enter into the application</li>
  <li>That's it. Enjoy the application.</li>
  <li>Click on the Refresh icon inside the application whenever needed to update your attendance</li>
</ul>

<img src="https://github.com/AndysTMC/Attendance-Tracker-SRMAP/assets/93911806/d6deb6c7-f4ca-4082-823f-f146910b0ef6" height="230" alt="WindowsAuthInterface">

<img src="https://github.com/AndysTMC/Attendance-Tracker-SRMAP/assets/93911806/a2301e30-d61e-4421-8f21-5ff193447c9e" height="230" alt="WindowsAttendanceInterface">

<img src="https://github.com/AndysTMC/Attendance-Tracker-SRMAP/assets/93911806/f33e400a-5edb-4f2d-9a3c-990e21a8d442" height="230" alt="WindowsDetailsInterface">

<img src="https://github.com/AndysTMC/Attendance-Tracker-SRMAP/assets/93911806/6edaef7a-2ae1-4e40-8246-e3233860d976" height="230" alt="WindowsScheduleInterface1">

<img src="https://github.com/AndysTMC/Attendance-Tracker-SRMAP/assets/93911806/34bb72a4-e66f-44bf-bab8-42d76ff120f7" height="230" alt="WindowsScheduleInterface2">

<img src="https://github.com/AndysTMC/Attendance-Tracker-SRMAP/assets/93911806/c339bf9f-4d7f-47e2-8854-9fbb3d2e3155" height="230" alt="WindowsScheduleInterface3">

