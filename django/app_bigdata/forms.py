from django import forms
from django.core.validators import MaxValueValidator, MinValueValidator

min_seconds = 2
max_seconds = 30


class NameForm(forms.Form):
    training_seconds = forms.IntegerField(label='Durata training in secondi', validators = [MinValueValidator(min_seconds), MaxValueValidator(max_seconds)])
    test_seconds = forms.IntegerField(label='Durata test in secondi', validators = [MinValueValidator(min_seconds), MaxValueValidator(max_seconds)])
