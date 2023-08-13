head -1 pathways/aster/asi_aster.csv > one_week_stopgap.csv

for flower in pathways/*
do
    pathway=$(basename $flower)
    head -2 pathways/$pathway/asi_$pathway.csv | tail -1 >> one_week_stopgap.csv
done