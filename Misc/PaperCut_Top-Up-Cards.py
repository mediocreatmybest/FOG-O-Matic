#!/usr/bin/env python3
# Creates:
# Print file for cards
# Import file for PaperCut NG/MF
# Not an offical PaperCut Script, re-written based on
# https://github.com/PaperCutSoftware/PaperCutExamples/tree/main/TopUpCards
# For more details about top up cards see https://www.papercut.com/kb/Main/TopUpCards
import locale
import random
import string
import sys
from datetime import datetime

from mailmerge import MailMerge

# Generate alphanumeric string for batch ID
def rand_alpha_string(length):
    characters = string.ascii_uppercase + string.digits
    clean_string = ''.join([c for c in characters if c not in '0OoIiLl'])
    returned_str = ''.join(random.choice(clean_string) for i in range(length))
    return returned_str




# Set locale for mailmerge
if sys.platform == "win32":
    # Set locale for Windows
    locale.setlocale(locale.LC_ALL, "English_Australia")
else:
    # Set locale for Linux/Other
    locale.setlocale(locale.LC_ALL, "en_AU.UTF-8")

# Input from users:
print()
print( """

      ######################################
      #    PaperCut Top-Up Card Generator  #
      ######################################

      """)

batch_id = input("Enter batch ID for cards: ")
card_value = float(input(f"Enter value to appear on each card: "))
number_of_cards = int(input(f'Enter number of cards to created in batch "{batch_id}", batches of 8 are best: '))
ext_date = input = input("Enter expiry date for cards (DD-MM-YYYY): ")

# Display value in local currency format
displayValue = locale.currency(card_value, grouping=True)
# Display value for date in local format
exp_date_display = datetime.strptime(ext_date, "%d-%m-%Y").strftime("%d/%m/%Y")
# Set ISO
ext_date_iso = datetime.strptime(ext_date, "%d-%m-%Y").date().isoformat()
# Set output name for files
save_file = batch_id + "_" + ext_date_iso

# Create import file for PaperCut
# Must be UTF-16 with correct BOM and MD-DOS line endings
importFile = open(f"{save_file}.tnd", mode="w", newline="\r\n", encoding='utf-16')
# PaperCut needs this header line in this format
importFile.write("CardNumber,BatchID,ValueNumber,Value,ExpDate,ExpDateDisplay\n")


# Merge template and MailMerge object
template = 'template.docx'
document = MailMerge(template)

# Set dict for cards to use later.
card_data = []
row_data = {}


# Generate card numbers, import file, and dict list
for i in range(number_of_cards):
    # Generate the string for the batch ID
    random_string = rand_alpha_string(4) + "-" + rand_alpha_string(4)
    # Card Number is the batch ID + random string (Hopefully this is unique enough: potential 36^8, or 2,821,109,907,456)
    card_number = batch_id + "-" + random_string

    print('Generating Card:', f'"{card_number}","{batch_id}","{card_value}","{displayValue}","{ext_date_iso}","{exp_date_display}"')

    # Add dict list for card_number, only really need card number
    card_data.append([{"card": card_number, "batch": batch_id}])

    # Create import file for PaperCut
    importFile.write(f'"{card_number}","{batch_id}","{card_value}","{displayValue}","{ext_date_iso}","{exp_date_display}"\n')


lst_row = []
cards = card_data
for i in range(0, len(cards), 8):
    row_data = {}
    for j in range(8):
        if i+j < len(cards):
            item = cards[i+j]
            card = item[0]['card']
            batch = item[0]['batch']
            row_data[f'CardNumber{j+1}'] = card
            row_data['Value'] = displayValue
            row_data['ExpDateDisplay'] = exp_date_display

    lst_row.append(row_data)

document.merge_templates(lst_row, separator='page_break')
document.write(f'{save_file}.docx')
print("File saved as: ", f"{save_file}.docx")