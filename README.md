# Histogram Transfer Based Reversible Data Hiding with Image Enhancement

This repository offers some codes for embedding test of the following paper:

Citation:
> Q. Ying, Z. Qian, X. Zhang, and D. Ye, Reversible Data Hiding with Image Enhancement using Histogram Shifting, IEEE Access, 7(1): 46506-46521, 2019.

PDF is available thru IEEE Xplore.

Usages:
It may takes several minutes for embedding and extracting (mainly depends on the size of input images)
User needs to rewrite some pathnames in the files.
Run encode.m and select host images in test_images. You can either randomly generate secret information (0-1 sequence with equal possibility), or you can compress secret images (or texts) into binary sequence as input.
Run decode.m to extract secret information and get the lossless host image.
Specially Thank to Professor Zhenxing Qian, Xinpeng Zhang from Shanghai University for kind help and offering some of the codes!
 
For more detailed information in RDH-CE, I may refer you to https://ieeexplore.ieee.org/document/6359955/

Contact me if you have any suggestion/new idea/comment or find any bug while using the codes via shinydotcom@163.com. And I will quickly reply.
