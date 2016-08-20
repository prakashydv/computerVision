//SSIM and PSNR for Video
#include <iostream>	// for standard I/O
#include <string>   // for strings
#include <iomanip>  // for controlling float print precision
#include <sstream>  // string to number conversion
#include <cstdio>
#include <fstream>

#include <opencv2/imgproc/imgproc.hpp>  // Gaussian Blur
#include <opencv2/core/core.hpp>        // Basic OpenCV structures (cv::Mat, Scalar)
#include <opencv2/highgui/highgui.hpp>  // OpenCV window I/O

using namespace std;
using namespace cv;

double getPSNR ( const Mat& I1, const Mat& I2);
Scalar getMSSIM( const Mat& I1, const Mat& I2);
double getVQM (const Mat& I1, const Mat& I2);
int main(int argc, char *argv[], char *window_name)
{
    
    stringstream conv;

    const string sourceReference = "bs9_25fps.avi",
	sourceCompareWith = "bs9_2000k.avi";
	
    int psnrTriggerValue, delay;
    conv << "35" << endl << "10";		  // put in the strings ------?
    conv >> psnrTriggerValue >> delay;// take out the numbers

    char c;
    int frameNum = -1;			// Frame counter
	
	cout<<"opening files to read ..."<<endl;
    
	VideoCapture captRefrnc(sourceReference),
        captUndTst(sourceCompareWith);

    if ( !captRefrnc.isOpened())
    {
        cout  << "Could not open reference " << sourceReference << endl;
        return -1;
    }

    if( !captUndTst.isOpened())
    {
        cout  << "Could not open case test " << sourceCompareWith << endl;
        return -1;
    }

    Size refS = Size((int) captRefrnc.get(CV_CAP_PROP_FRAME_WIDTH),
        (int) captRefrnc.get(CV_CAP_PROP_FRAME_HEIGHT)),
        uTSi = Size((int) captUndTst.get(CV_CAP_PROP_FRAME_WIDTH),
        (int) captUndTst.get(CV_CAP_PROP_FRAME_HEIGHT));

    if (refS != uTSi)
    {
        cout << "Inputs have different size!!! Closing." << endl;
        return -1;
    }

    const char* WIN_UT = "Under Test";
    const char* WIN_RF = "Reference";
	const char* WIN_TEST = "Test";
    // Windows
    //namedWindow(WIN_RF, CV_WINDOW_AUTOSIZE );
    namedWindow(WIN_UT, CV_WINDOW_AUTOSIZE );
	//namedWindow(WIN_TEST, CV_WINDOW_AUTOSIZE );
    //cvMoveWindow(WIN_RF, 400       ,            0);		 //750,  2 (bernat =0)
    cvMoveWindow(WIN_UT, refS.width,            0);		 //1500, 2

	ofstream fout("Video_stats.txt");
		
    cout << "Reference frame resolution: Width=" << refS.width << "  Height=" << refS.height
        << " of nr#: " << captRefrnc.get(CV_CAP_PROP_FRAME_COUNT) << endl;

    cout << "PSNR trigger value " <<
        setiosflags(ios::fixed) << setprecision(3) << psnrTriggerValue << endl;

    Mat frameReference, frameUnderTest,testFrame;
    double psnrV;
    Scalar mssimV;
	int mssimFound=0;
	std::string mssimText;
	


    while( true) //Show the image captured in the window and repeat
    {
        captRefrnc >> frameReference;
        captUndTst >> frameUnderTest;
		//testFrame=abs(frameReference-frameUnderTest);


        if( frameReference.empty()  || frameUnderTest.empty())
        {
            cout << " < < <  Game over!  > > > ";
            break;
        }

        ++frameNum;
        cout <<"Frame:" << frameNum <<"# ";

        ///////////////////////////////// PSNR ////////////////////////////////////////////////////
        psnrV = getPSNR(frameReference,frameUnderTest);					//get PSNR
        cout << setiosflags(ios::fixed) << setprecision(3) << psnrV << "dB";
		fout << setiosflags(ios::fixed) << setprecision(3) << psnrV <<"\t";
		//////////////////////////////////// MSSIM /////////////////////////////////////////////////
		
        if (psnrV < psnrTriggerValue && psnrV)
        {
			mssimFound=3;
            mssimV = getMSSIM(frameReference,frameUnderTest);

            cout << "MSSIM: "
                << " R " << setiosflags(ios::fixed) << setprecision(2) << mssimV.val[2] * 100 << "%"
                << " G " << setiosflags(ios::fixed) << setprecision(2) << mssimV.val[1] * 100 << "%"
                << " B " << setiosflags(ios::fixed) << setprecision(2) << mssimV.val[0] * 100 << "%";
			fout <<setiosflags(ios::fixed) << setprecision(2) << mssimV.val[2] * 100 << "\t"
                 << setiosflags(ios::fixed) << setprecision(2) << mssimV.val[1] * 100 << "\t"
                << setiosflags(ios::fixed) << setprecision(2) << mssimV.val[0] * 100 << "\t";
			ostringstream ss;
			ss << "MSSIM: "
                << " R " << setiosflags(ios::fixed) << setprecision(2) << mssimV.val[2] * 100 << "%"
                << " G " << setiosflags(ios::fixed) << setprecision(2) << mssimV.val[1] * 100 << "%"
                << " B " << setiosflags(ios::fixed) << setprecision(2) << mssimV.val[0] * 100 << "%";
			mssimText= ss.str();
        }

        cout << endl;
		
        ////////////////////////////////// Show Image /////////////////////////////////////////////
		//add psnr to video
		ostringstream ss;
		double vqm=getVQM(frameReference,frameUnderTest);
		ss <<"PSNR: "<<psnrV<<" VQM : "<<vqm;
		std::string psnrText = ss.str();
		putText(frameUnderTest,psnrText,Point(30,30),FONT_HERSHEY_PLAIN,1.2, Scalar(0,255,255));
		fout<<vqm<<endl;
		
		//add mssim if it exists
		if(mssimFound>0)
		{
			putText(frameUnderTest,mssimText,Point(30,50),FONT_HERSHEY_PLAIN,1.2, Scalar(0,0,255));
			mssimFound--;
		}
        //imshow( WIN_RF, frameReference);
        imshow( WIN_UT, frameUnderTest);
		//imshow( WIN_TEST, testFrame);

        c = cvWaitKey(delay);
        if (c == 27) break;
    }
	fout.close();
    return 0;
}

double getVQM (const Mat& I1, const Mat& I2) {
//source for getVQM: https://code.google.com/p/cpp-image-quality/source/browse/opencv/opencv.cpp
        // MPEG Matrix
        Mat mpeg = (Mat_<double>(8,8) << 
                8, 16, 19, 22, 26, 27, 29, 34,
                16, 16, 22, 24, 27, 29, 34, 37,
                19, 22, 26, 27, 29, 34, 34, 38,
                22, 22, 26, 27, 29, 34, 37, 40,
                22, 26, 27, 29, 32, 35, 40, 48,
                26, 27, 29, 32, 35, 40, 48, 58,
                26, 27, 29, 34, 38, 46, 56, 69,
                27, 29, 35, 38, 46, 56, 69, 83);

        double maxElem = 0, absSum = 0;
        std::vector<double> maxim;
        std::vector<double>::iterator it;
        double calcBuff = 0;
        Mat absDiff;
        Mat i1, i2;
        Mat i1block, i2block;
        Mat dct1, dct2;
        Mat lc1, lc2;
        Scalar sumScalar;

        cvtColor(I1,i1,CV_RGB2GRAY);
        cvtColor(I2,i2,CV_RGB2GRAY);
        mpeg.convertTo(mpeg, CV_32FC1);
        i1.convertTo(i1,CV_32FC1);
        i2.convertTo(i2,CV_32FC1);
        

        // take block of 8x8 of image1
        for (int i=0; i<i1.cols; i=i+8) {
                if (i > i1.cols - 8) { 
                        break; 
                } 
                for (int j=0; j < i1.rows; j=j+8) {
                        if (j > i1.rows - 8) { 
                                break; 
                        } 

						//extract a 8x8 tile from frame
                        i1block = i1(Rect(i,j,8,8));
                        i2block = i2(Rect(i,j,8,8));

                        //perform DCT
                        dct(i1block, dct1, CV_DXT_FORWARD);
                        dct(i2block, dct2, CV_DXT_FORWARD);

                        // get DC coefficients
                        double dc1 = dct1.at<float>(0,0);
                        double dc2 = dct2.at<float>(0,0);

                        dc1 = pow (dc1/1024, 0.65) / dc1;
                        dc2 = pow (dc2/1024, 0.65) / dc2;
                        lc1 = dct1.mul(dc1);
                        lc2 = dct2.mul(dc2);
                        
                        lc1 = lc1/mpeg;
                        lc2 = lc2/mpeg;
                        
                        absdiff(lc1,lc2,absDiff);
                        
                        sumScalar = sum(absDiff);
                        calcBuff = (sumScalar.val[0] + sumScalar.val[1] + sumScalar.val[2])/3;
                        absSum = absSum + calcBuff;
                        
                        minMaxLoc(absDiff, NULL, &calcBuff);
                        maxim.push_back(calcBuff);
                }
        }
        it = max_element(maxim.begin(), maxim.end());
        maxElem = *it;
        return 10 * ((1000 * absSum)/(i1.cols*i1.rows) + 5 * maxElem);
}
double getPSNR(const Mat& I1, const Mat& I2)
{
    Mat s1;
    absdiff(I1, I2, s1);       // |I1 - I2|
    s1.convertTo(s1, CV_32F);  // cannot make a square on 8 bits
    s1 = s1.mul(s1);           // |I1 - I2|^2

    Scalar s = sum(s1);         // sum elements per channel

    double sse = s.val[0] + s.val[1] + s.val[2]; // sum channels

    if( sse <= 1e-10) // for small values return zero
        return 0;
    else
    {
        double  mse =sse /(double)(I1.channels() * I1.total());
        double psnr = 10.0*log10((255*255)/mse);
        return psnr;
    }
}

Scalar getMSSIM( const Mat& i1, const Mat& i2)
{
    const double C1 = 6.5025, C2 = 58.5225;
    //INITS 
	int d     = CV_32F;

    Mat I1, I2;
    i1.convertTo(I1, d);           // cannot calculate on one byte large values
    i2.convertTo(I2, d);

    Mat I2_2   = I2.mul(I2);        // I2^2
    Mat I1_2   = I1.mul(I1);        // I1^2
    Mat I1_I2  = I1.mul(I2);        // I1 * I2
	//END INITS 

    Mat mu1, mu2;   // PRELIMINARY COMPUTING
    GaussianBlur(I1, mu1, Size(11, 11), 1.5);
    GaussianBlur(I2, mu2, Size(11, 11), 1.5);

    Mat mu1_2   =   mu1.mul(mu1);
    Mat mu2_2   =   mu2.mul(mu2);
    Mat mu1_mu2 =   mu1.mul(mu2);

    Mat sigma1_2, sigma2_2, sigma12;

    GaussianBlur(I1_2, sigma1_2, Size(11, 11), 1.5);
    sigma1_2 -= mu1_2;

    GaussianBlur(I2_2, sigma2_2, Size(11, 11), 1.5);
    sigma2_2 -= mu2_2;

    GaussianBlur(I1_I2, sigma12, Size(11, 11), 1.5);
    sigma12 -= mu1_mu2;

    ///////////////////////////////// FORMULA ////////////////////////////////
    Mat t1, t2, t3;

    t1 = 2 * mu1_mu2 + C1;
    t2 = 2 * sigma12 + C2;
    t3 = t1.mul(t2);              // t3 = ((2*mu1_mu2 + C1).*(2*sigma12 + C2))

    t1 = mu1_2 + mu2_2 + C1;
    t2 = sigma1_2 + sigma2_2 + C2;
    t1 = t1.mul(t2);               // t1 =((mu1_2 + mu2_2 + C1).*(sigma1_2 + sigma2_2 + C2))

    Mat ssim_map;
    divide(t3, t1, ssim_map);      // ssim_map =  t3./t1;

    Scalar mssim = mean( ssim_map ); // mssim = average of ssim map
    return mssim;
}