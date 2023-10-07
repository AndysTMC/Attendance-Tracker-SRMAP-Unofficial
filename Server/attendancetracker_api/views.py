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
        holidays = [['Independence Day', '2023-08-15'],
                    ['Sri Krishna Ashtami', '2023-09-07'],
                    ['Vinayaka Chavithi', '2023-09-19'],
                    ['Eid Milanun Nabi', '2023-09-28'],
                    ['Mahatma Gandhi Jayanthi', '2023-10-02'],
                    ['Vijayadasami', '2023-10-24'],
                    ['Karthika Purnima', '2023-11-27'],
                    ['Christmas', '2023-12-25']]
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
