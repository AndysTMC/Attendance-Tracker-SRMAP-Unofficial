from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
from .models import WebActions


@csrf_exempt
def get_attendance_view(request):
    if request.method == 'POST':
        # Assuming the request contains student_id and student_name
        student_id = request.POST.get('student_id')
        student_dob = request.POST.get('student_dob')
        student_first_time_login = bool(request.POST.get('first_time_login'))
        attendant = WebActions(student_id, student_dob, student_first_time_login)
        holidays = [["Republic Day", "2024-01-26"],
                    ["Maha Shivaratri", "2024-03-08"],
                    ["Holi", "2024-03-25"],
                    ["Good Friday", "2024-03-29"],
                    ["Babu Jagjivan Ram's Birthday", "2024-04-05"],
                    ["Ugadi", "2024-04-09"],
                    ["Eid-ul-Fitr", "2024-04-11"],
                    ["Dr. B.R. Ambedkar's Birthday", "2024-04-14"],
                    ["Sri Rama Navami", "2024-04-17"]]
        try:
            name, attendance_tracker, timetable = attendant.get_data()
            attendance = attendance_tracker.attendances
        except Exception as e:
            print(str(e))
            return JsonResponse({'status': -1})
        # set status tof response to 200 if successful
        return JsonResponse(
            {'status': 0, 'name': name, 'attendance': attendance, 'timetable': timetable, 'holidays': holidays})
    else:
        return HttpResponse("Invalid request method")


@csrf_exempt
def send_email_view(request):
    if request.method == 'POST':
        # Assuming the request contains student_id, student_name, and email
        student_id = request.POST.get('student_id')
        student_dob = request.POST.get('student_dob')
        email = request.POST.get('email')
        attendant = WebActions(student_id, student_dob, False)
        pass
        return JsonResponse({"status": 0})
    else:
        return HttpResponse("Invalid request method")
