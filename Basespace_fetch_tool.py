import csv
import pandas

sample_sheet_file=open("Sample_sheet.txt")
split_file=pandas.read_csv(sample_sheet_file, delimiter="-", header=None)
print(split_file)
print(split_file[1])