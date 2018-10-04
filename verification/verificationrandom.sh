#!/bin/bash
module load ncl/6.2.1
source ~/.nclrc_hailcast

month=june
for day in 601 602 603 604 605 606 609 612 614 615 616 620 621 622 623 624 625 626 627 628 629 630
do
  ncl verificationrandom.ncl 'inputmonth="'${month}'"' 'inputday="'${day}'"'
done
echo $month date

month=july
for day in 701 702 705 707 708 709 710 711 712 714 718 719 720 721 722 723 724 725 726 727 728 729 730 731
do 
  ncl verificationrandom.ncl 'inputmonth="'${month}'"' 'inputday="'${day}'"'
done
echo $month date

month=august
for day in 801 802 803 804 805 806 808 809 810 811 812 814 815 816 817 818 819 823 824 825 826 828 831
do 
  ncl verificationrandom.ncl 'inputmonth="'${month}'"' 'inputday="'${day}'"'
done
echo $month date


