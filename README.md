# Histogram Transfer Based Reversible Data Hiding with Image Enhancement

This repository offers some codes for embedding test of the following paper:

Citation:
> Q. Ying, Z. Qian, X. Zhang, and D. Ye, Reversible Data Hiding with Image Enhancement using Histogram Shifting, IEEE Access, 7(1): 46506-46521, 2019.

PDF is available through IEEE Xplore:
> https://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=8682110

Abstract:
Traditional reversible data hiding (RDH) focuses on enlarging the embedding payloads while minimizing the distortion with a criterion of mean square error (MSE). Since imperceptibility can also be achieved via image processing, we propose a novel method of RDH with contrast enhancement (RDH-CE) using histogram shifting. Instead of minimizing the MSE, the proposed method generates marked images with good quality with the sense of structural similarity. The proposed method contains two parts: the baseline embedding and the extensive embedding. In the baseline part, we first merge the least significant bins to reserve spare bins and then embed additional data by a histogram shifting approach using arithmetic encoding. During histogram shifting, we propose to construct the transfer matrix by maximizing the entropy of the histogram. After embedding, the marked image containing additional data has a larger contrast than the original image. In the extensive embedding part, we further propose to concatenate the baseline embedding with an MSE-based embedding. On the recipient side, the additional data can be extracted exactly, and the original image can be recovered losslessly. Comparing with existing RDH-CE approaches, the proposed method can achieve a better embedding payload.

Usages:
It may takes several minutes for embedding and extracting (mainly depends on the size of input images). User needs to rewrite some pathnames in the files.
Run encode.m and select host images in test_images. You can either randomly generate secret information (0-1 sequence with equal possibility), or you can compress secret images (or texts) into binary sequence as input.
Run decode.m to extract secret information and get the lossless host image.

 
Acknowledgment:
Specially Thank to Professor Zhenxing Qian, Xinpeng Zhang from Fudan University for kindly offering guidance and help in this work!
For more detailed information in RDH-CE, I may refer you to a well-known efficient data hiding scheme called "Reversible Data Hiding With Optimal Value Transfer", which is proposed by my professor Dr. Xinpeng Zhang from Fudan University.
Citation:
> Zhang X. Reversible data hiding with optimal value transfer[J]. IEEE Transactions on Multimedia, 2012, 15(2): 316-325.

Link:
> https://ieeexplore.ieee.org/document/6359955/

Contact me if you have any suggestion/comment or find any bug while using the codes, or new idea about RDH-CE or even applying deep neural network(DNN) on RDH (which seems to be impossible so far simply cuz no way can we strictly let the training loss equal to zero), via:
Email: 
> shinydotcom@163.com.
Wechat account:
> acshu123
Twitter account:
>Shinylaa
And I will quickly reply. :)
