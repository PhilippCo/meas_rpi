cd /home/pi/notebooks/cron/nightly

for f in *.ipynb; do
  jupyter nbconvert --to html --execute "$f" 
done
