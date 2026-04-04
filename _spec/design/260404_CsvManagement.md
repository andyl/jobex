# Csv Management

## Phase 1 

CSV Root Directory

- Establish an environment variable JOBEX_CSV_DIR 
- Location where CSV files live 
- Default: priv/csv (read only)

CSV File Management 

- On the **admin** page, present a list of CSV file
- Show each file: file_name, # of lines, last updated
- Action buttons for each file: select, rename, preview, delete 
- For preview: show the CSV data in a popup-modal or a sidebar or a separate page 
- For delete: show a confirmation window!!
- Be mindful: every UI screen must work on mobile - responsive UI
- It's acceptable to disable certain features on narrow screens
- Disable preview on narrow screens

Also show: 
- the currently selected file 
- a button or form to create a new file 

Re: csv filenames 
- spaces not allowed 
- valid characters: lowercase, numbers and underscores only 

When selected: load the CSV file and start running jobs

Remembering the selected file 
- don't store the selected filename in the database
- if the JOBEX_CSV_DIR is writable, store the selected filename in the .jobex.yml file

## Phase 2 

CSV file editing 

- On the **schedule** page, show:
    * currently selected CSV file 
    * all jobs in the CSV file 
    * a "create job" button or form 
- For each job show:
    * SCHEDULE, QUEUE, TYPE, COMMAND 
    * an edit and delete button  
- When a row is edited or deleted, load the job, and update the CSV file

