//ITS objective quality measure for Video
#include <iostream>	// for standard I/O
#include <string>   // for strings
#include <iomanip>  // for controlling float print precision
#include <sstream>  // string to number conversion

#include <opencv2/imgproc/imgproc.hpp>  // Gaussian Blur
#include <opencv2/core/core.hpp>        // Basic OpenCV structures (cv::Mat, Scalar)
#include <opencv2/highgui/highgui.hpp>  // OpenCV window I/O
#define max(a,b) (a>b)?a:b
#define absol(a) (a>0)?a:-a
using namespace std;
using namespace cv;
double spatialInfo(Mat I);
double temporalInfo(Mat I,Mat J);
double func(double TI_O,double TI_D);
int zzmain(int argc, char *argv[], char *window_name)
{
    string rootfolder="C:/Video/";
	
	vector <string> Vidfiles;
	string source="bs/bs9_25fps.avi";
	//Vidfiles.push_back("bs/bs9_25fps.avi");
	Vidfiles.push_back("bs/bs10_25fps.avi");
	//Vidfiles.push_back("bs/bs11_25fps.avi");
	//Vidfiles.push_back("bs/bs12_25fps.avi");
	int numOfFiles=1;
	for(int filenum=0;filenum<numOfFiles;filenum++)
	{
		const string sourceReference =rootfolder+source,
		sourceCompareWith =rootfolder+Vidfiles[filenum];
	
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

    
		// Windows
		//const char* WIN_DIFF = "Difference";
		//namedWindow(WIN_DIFF, CV_WINDOW_AUTOSIZE );
   
		cout << "Reference frame resolution: Width=" << refS.width << "  Height=" << refS.height
			<< " of nr#: " << captRefrnc.get(CV_CAP_PROP_FRAME_COUNT) << endl;

		Mat frameReference, frameUnderTest;
		Mat frameReference_old,frameUnderTest_old;
		double m1=0.0,m2=0.0,m3=0.0;
		double SI_O=0.0,SI_D=0.0,TI_O=0.0,TI_D=0.0;
		vector <double> M2acc;
		while( true) //Show the image captured in the window and repeat
		{
			captRefrnc >> frameReference;
			captUndTst >> frameUnderTest;
		
			if( frameReference.empty()  || frameUnderTest.empty())
			{
				cout << "Finish ... ";
				break;
			}
			cvtColor( frameReference,frameReference, CV_RGB2GRAY );//convert to grayscale
			cvtColor( frameUnderTest,frameUnderTest, CV_RGB2GRAY );//convert to grayscale

			/////////// Spatial and Temporal Info /////////////
			SI_O=spatialInfo(frameReference);
			SI_D=spatialInfo(frameUnderTest);
			//cout<<"SIO:"<<SI_O<<"  SID:"<<SI_D<<endl;
		
			if(frameNum!=-1)
			{
				TI_O=temporalInfo(frameReference,frameReference_old);
				TI_D=temporalInfo(frameUnderTest,frameUnderTest_old);
				//cout<<"TIO:"<<TI_O<<"  TID:"<<TI_D<<endl;
			}
			else
			{
				frameReference_old=frameReference;
				frameUnderTest_old=frameUnderTest;
			}
		

			++frameNum;
			cout <<"\rFrame:" << frameNum <<"# ";
			/////////////// Calculate m1 m2 m3 /////////////////////////
			if(SI_O!=0)
			{
				double prod=(5.81*(absol((SI_O-SI_D)/SI_O)))*(5.81*(absol((SI_O-SI_D)/SI_O)));
				m1=m1+prod;
				//cout<<m1<<"<--->"<<prod;
			}
		
			M2acc.push_back(func(TI_O,TI_D));

			if(TI_O > 0.0 && TI_D > 0.0) 
				m3=max(4.23*(log(TI_D)/log(TI_O)),0.0);

			//cout<<"M1:"<<m1<<"  M3:"<<m3<<endl;
			////////////////////////////////// Show Image /////////////////////////////////////////////
		
			c = cvWaitKey(10);
			if (c == 27) break;
		}
	
		m1=sqrt(m1/frameNum);

		Scalar mean,stddev;
		meanStdDev(M2acc,mean,stddev);
		m2=stddev[0];

		cout<<"\nM1:"<<m1<<"\nM2:"<<m2<<"\nM3:"<<m3<<endl; 
		double c1=-0.992,c2=-0.272,c3=-0.356;
		double quality=4.77+c1*m1+c2*m2+c2*m3;
		cout<<Vidfiles[filenum]+" Quality: "<<quality<<endl;
	}
    return 0;
}

double spatialInfo(Mat I)
{
	Mat grad_x, grad_y,grad;
	Mat abs_grad_x, abs_grad_y;
	
	Sobel( I, grad_x, CV_16S, 1, 0, 3, 1, 0, BORDER_DEFAULT );
	convertScaleAbs( grad_x, abs_grad_x );
	Sobel( I, grad_y, CV_16S, 0, 1, 3, 1, 0, BORDER_DEFAULT );
	convertScaleAbs( grad_y, abs_grad_y );
	addWeighted( abs_grad_x, 0.5, abs_grad_y, 0.5, 0, grad );

	Scalar mean,stddev;
	meanStdDev(grad,mean,stddev);
	
	return stddev[0];
}

double temporalInfo(Mat I,Mat J)
{
	Scalar mean,stddev;
	Mat diff=I-J;
	meanStdDev(diff,mean,stddev);
	return stddev[0];
}

double func(double TI_O,double TI_D)
{
	double x=0.108*(max(0,TI_O-TI_D));
	//convolution
	double conv[]={-1.0*x,2.0*x,-1.0*x};
	double mu=(conv[0]+conv[1]+conv[2])/3;
	double stddev=sqrt(((conv[0]-mu)*(conv[0]-mu)+(conv[1]-mu)*(conv[1]-mu)+(conv[2]-mu)*(conv[2]-mu))/3);
	return stddev;
}