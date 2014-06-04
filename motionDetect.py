import numpy,cv2,time

cv2.namedWindow("preview")
vc = cv2.VideoCapture(0)

if vc.isOpened(): # try to get the first frame
    rval, im1 = vc.read()
    
else:
    rval = False
    print "Unable to capture from webcam!"
    cv2.destroyWindow("preview")
    exit()

cv2.imshow("preview", im1)
while rval:
	time.sleep(0.25)
	rval, im2 = vc.read()
	
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
	imtext="X:%0.2f  Y:%0.2f"%(mean2x-mean1x,mean2y-mean1y)
	cv2.putText(im2,imtext,(5,5), cv2.FONT_HERSHEY_SIMPLEX, 2, 255)	

	img2 = cv2.drawKeypoints(im2, kp2, color=(255,0,0))
	cv2.imshow("preview", img2)

	print imtext
	im1=im2
	
	key = cv2.waitKey(20)
    	if key == 27: # exit on ESC
    	    break
end
cv2.destroyWindow("preview")


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


