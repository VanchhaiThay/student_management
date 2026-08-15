import re

with open(r'd:\flutter_project\student_management\lib\screens\teacher_signup_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Define segments and filenames
header_match = re.search(r'(// -- Header -+.*?)(?=// -- Form Card)', content, re.DOTALL)
form_match = re.search(r'(// -- Form Card -+.*?)(?=// -- Branding Panel)', content, re.DOTALL)
branding_match = re.search(r'(// -- Branding Panel -+.*?)(?=// -- Background Blobs)', content, re.DOTALL)
blobs_match = re.search(r'(// -- Background Blobs -+.*)', content, re.DOTALL)

imports = '''import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
'''

def write_widget(filename, code):
    if not code: return
    # remove private underscores from classes if we want, but let's just make them public for the widgets
    code = code.group(1)
    code = code.replace('class _', 'class ')
    code = code.replace('_VisibilityBtn', 'VisibilityBtn')
    code = code.replace('_TermsCheckbox', 'TermsCheckbox')
    code = code.replace('_SubmitButton', 'SubmitButton')
    code = code.replace('_DepartmentDropdown', 'DepartmentDropdown')
    code = code.replace('_SignInRow', 'SignInRow')
    with open(rf'd:\flutter_project\student_management\lib\screens\signup\widgets\{filename}', 'w', encoding='utf-8') as out:
        out.write(imports + '\n' + code)

write_widget('signup_header.dart', header_match)
write_widget('signup_form_card.dart', form_match)
write_widget('signup_branding_panel.dart', branding_match)
write_widget('signup_background_blobs.dart', blobs_match)

print("Widgets extracted")
