cd /home/pi/notebooks/cron/hourly

for f in *.ipynb; do
  /home/pi/.local/bin/jupyter nbconvert --to html --execute "$f" 
done
