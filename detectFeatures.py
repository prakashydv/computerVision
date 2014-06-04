import numpy,cv2
im1=cv2.imread("2014-06-04-150607.jpg",cv2.CV_LOAD_IMAGE_GRAYSCALE)
im2=cv2.imread("2014-06-04-150613.jpg",cv2.CV_LOAD_IMAGE_GRAYSCALE)

fast = cv2.FastFeatureDetector()

kp1 = fast.detect(im1,None)
kp2 = fast.detect(im2,None)

mean1x,mean1y,mean2x,mean2y=0,0,0,0
for p in kp1:
	mean1x+=p.pt[0]
	mean1y+=p.pt[1]
for p in kp2:
	mean2x+=p.pt[0]
	mean2y+=p.pt[1]
mean1x/=len(kp1)
mean1y/=len(kp1)

mean2x/=len(kp2)
mean2y/=len(kp2)

print mean2x-mean1x,mean2y-mean1y

"""
img1 = cv2.drawKeypoints(im1, kp1, color=(255,0,0))
img2 = cv2.drawKeypoints(im2, kp2, color=(255,0,0))

print "Threshold: ", fast.getInt('threshold')
print "nonmaxSuppression: ", fast.getBool('nonmaxSuppression')
print "Total Keypoints in image1: ", len(kp1)
print "Total Keypoints in image2: ", len(kp2)

cv2.imwrite('features1.png',img1)
cv2.imwrite('features2.png',img2)

"""


