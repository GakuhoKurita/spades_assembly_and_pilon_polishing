#220922
#Gakuho Kurita
#spades asssembly and pilon polishing
#v0.1
cat list | while read line
do
 R1=$line
 R2=${line%1.fq}2.fq
 spadesdir=${line%_1.fq}
 contig1=${line%_1.fq}_1.fasta
 bam1=${line%_1.fq}_1.bam
 bam2=${line%_1.fq}_2.bam
 bam3=${line%_1.fq}_3.bam
 pilon1=${line%_1.fq}_pilon1
 pilon2=${line%_1.fq}_pilon2
 pilon3=${line%_1.fq}_pilon3
 echo $spadesdir
 spades.py -1 $R1 -2 $R2 -o $spadesdir -t 16 --only-assembler -k 21 --cov-cutoff 5
 sqkit stats -a $spadesdir/contigs.fasta >> stats
 seqkit seq -m 1000 $spadesdir/contig.fasta > $contig1

 minimap2 -ax sr -t16 $contig1 $R1 $R2 | samtools sort -@8 - > $bam1
 samtools index $bam1
 java -jar /home/numbl2/miniforge3/bin/pilon-1.24.jar --genome $contig1 --frags $bam1 --changes --threads 8 --outdir $pilon1 --diploid
 seqkit stats -a $pilon1/pilon.fasta >> stats

 minimap2 -ax sr -t16 $pilon1/pilon.fasta $R1 $R2 | samtools sort -@8 - > $bam2
 samtools index $bam2
 java -jar /home/numbl2/miniforge3/bin/pilon-1.24.jar --genome $pilon1/pilon.fasta --frags $bam2 --changes --threads 8 --outdir $pilon2 --diploid
 seqkit stats -a $pilon2/pilon.fasta >> stats

 minimap2 -ax sr -t16 $pilon2/pilon.fasta $R1 $R2 | samtools sort -@8 - > $bam3
 samtools index $bam3
 java -jar /home/numbl2/miniforge3/bin/pilon-1.24.jar --genome $pilon2/pilon.fasta --frags $bam3 --changes --threads 8 --outdir $pilon3 --diploid
 seqkit stats -a $pilon3/pilon.fasta >> stats
done