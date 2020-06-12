/*
 *			       Thomas Kuehnel
 *			       24.02.1998
 *                             tk@mail.glg.ed.ac.uk
 *                             http://www.glg.ed.ac.uk/home/Thomas.Kuehnel
 *                                                      
 * gcc minimax.c -lm -o Minma
 *
 * Program to calculate the min/max values of a data set,
 *   construct a gmt cpt file, a shell script and execute it
 *   it automatically find the number of columns in the data 
 *   (2,3 or 4 are allowed. If 4 is used it is assumed that the data
 *   structure is ID x y z.
 *
 * -f input file 2, 3 or 4D (default stdin)
 * -base percent of basemap larger than the data (Default = 2.0)
 * -prefix Prefix of all file names (.info, .cpt, .sh, .ps) (default mm)
 * -info file name of the info file 
 * -cpt file name of the cpt file 
 * -gmt file name of the gmt script
 * -ps file name of the PS file 
 * -prec precision of the cpt output (default 3)
 * -is switch for different colour scales (default =12)
 * -add switch to add a white segment between 0.0 and zmin
 *    (default=0)
 * -pc percent added to dz to extend the colour scale (default = 0.0)
 * -nan ignore these values (default -99.0)
 * -notrun switch to undo the  excution of the script 
 * -xsize Plot size x in inches (default 6.0)
 * -ysize Plot size y in inches (default xsize)
 * -title Plot title (default input file name)
 * -eps precision how good to hit nan
 * -checkz for 3 and 4 colums check if z=nan (default check not)
 * -psxy use psxy instaed of grd for 3D plots
 * added the ignoration of header lines 11.6.98
 * -h number of lines at the beginning of the file to ignore
 * -columns give the number of columns in the input file. This can
 *          sometims be neccessary as the automatic detection fails 
 *          if there is a space after the final column.
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>
#include <curses.h>

extern    void  assignColor(int  ColorSwitch, char *color[50][3]);
extern    void	gmtplot( int    InputFormat,    /* Switch for input data*/
			 char	*inputfileName,	/* (ffid) xy (z) data	 */
			 char	*psfileName,	/* final postscript file */
			 char   *cptfileName,   /* gmt colour file */
			 char	*gmtfileName,	/* temporary script file */
			 float	xmin,		/**/
			 float	xmax,		/**/
			 float	ymin,	        /**/
			 float	ymax,	        /**/
			 float  base,           /* percentage to extend the basemap */
			 float  xsize,
			 float  ysize,
                         char  *title,
			 int    OutputFormat,
			 int    header);
extern void exgmt (char *gmtfileName);

void	main (int argc, char **argv)

{ FILE      *inputfile,*cptfile,*infofile;
 
  int       add;
  int       ColorSwitch,InputFormat,RunGmt;
  int       OutputFormat;
  int       i,count,count2;
  int       EndOfFile;
  int       parts;
  int       prec;
  int       checkz;
  int       go;
  int       header;
  int       columns;

  float     base,percent,nan;
  float     w,x,y,z;
  float     xmin,xmax,ymin,ymax,zmin,zmax;
  float     dz_old,dz,z_interval,zmin_help,z1,z2,extra_z;
  float     eps;
  float     xsize,ysize;
  float     zmin_x,zmin_y,zmax_x,zmax_y;
  float     ymax_x,ymin_x;
  
 
  char      *inputfileName;
  char      cptfileName[1024];
  char      gmtfileName[1024];
  char      psfileName[1024],infofileName[1024];
  char      *color[50][3];
  char      format[1024];
  char      prefix[1024];
  char      *dummy;
  char      line1[1024],title[1024];
  char      output_program[1024];



  sprintf (cptfileName,"%s","");
  sprintf (gmtfileName,"%s","");
  sprintf (psfileName,"%s","");
  sprintf (infofileName,"%s","");
  sprintf (prefix,"%s","");

  /* Default values */

  base=2.0;
  ColorSwitch=12;
  add=0;
  percent=0.0;
  nan=-99.0;
  RunGmt=1;
  prec=3;
  sprintf (prefix,"%s","mm");
  eps=0.0001;
  xsize=6.0;
  ysize=xsize;
  checkz=0;
  sprintf(title,"%s","Title");
  OutputFormat=0;
  sprintf(output_program,"%s","nearneighbour+grdview");
  header=0;
  columns=0;
  
    for (i=0; i<argc; i++) {

      if (strcmp(argv[i],"-f")==0) {
	inputfileName= (char *) strdup (argv[++i]);
	sprintf(title,"%s",inputfileName);
      }
      if (strcmp(argv[i],"-prefix")==0)  sprintf (prefix,"%s",argv[++i]);
      if (strcmp(argv[i],"-info")==0)    sprintf(infofileName,"%s",argv[++i]);
      if (strcmp(argv[i],"-cpt")==0)     sprintf(cptfileName,"%s",argv[++i]);
      if (strcmp(argv[i],"-gmt")==0)     sprintf(gmtfileName,"%s",argv[++i]);
      if (strcmp(argv[i],"-ps")==0)      sprintf(psfileName,"%s",argv[++i]);
      if (strcmp(argv[i],"-is")==0) sscanf (argv[++i], "%d",&ColorSwitch);
      if (strcmp(argv[i],"-add")==0) add=1;
      if (strcmp(argv[i],"-notrun")==0) RunGmt=0;  
      if (strcmp(argv[i],"-base")==0) sscanf (argv[++i], "%f", &base);
      if (strcmp(argv[i],"-pc")==0)  sscanf (argv[++i], "%f", &percent);
      if (strcmp(argv[i],"-nan")==0) sscanf (argv[++i], "%f", &nan); 
      if (strcmp(argv[i],"-prec")==0) sscanf (argv[++i], "%d", &prec);
      if (strcmp(argv[i],"-xsize")==0) sscanf (argv[++i], "%f", &xsize); 
      if (strcmp(argv[i],"-ysize")==0) sscanf (argv[++i], "%f", &ysize); 
      if (strcmp(argv[i],"-title")==0)      sprintf(title,"%s",argv[++i]);
      if (strcmp(argv[i],"-eps")==0) sscanf (argv[++i], "%f", &eps); 
      if (strcmp(argv[i],"-h")==0) sscanf (argv[++i], "%d", &header); 
      if (strcmp(argv[i],"-columns")==0) sscanf (argv[++i], "%d",&columns); 
      if (strcmp(argv[i],"-checkz")==0) checkz=1;
      if (strcmp(argv[i],"-psxy")==0) {
	OutputFormat=1;
	sprintf(output_program,"%s","psxy");
      }
    }

    if (inputfileName == NULL) {
      inputfile=stdin;
    }
    else {
      
      if ( (inputfile= fopen (inputfileName, "r")) == NULL ) 
	{
	  fprintf (stderr, "\nCan't open file %s\n", inputfileName);
	  exit(-1);
	}    
    }

    if (strlen(infofileName) == 0) {
      sprintf(infofileName,"%s.info",prefix);
    }
    
    infofile= fopen (infofileName, "w");
    fprintf (stderr,"\nI have opened the file %s\n",infofileName);
    
    if (strlen(gmtfileName) == 0) {
      sprintf(gmtfileName,"%s.sh",prefix);
    }

    if (strlen(psfileName) == 0) {
      sprintf(psfileName,"%s.ps",prefix);
    }

    /* Find out how many colums we have if the number is not given in
     * the command line */

    if (columns!=0) {
   	InputFormat=columns;
    }
    else {
    
    /* Ignore the header lines */
    
       for (i=0; i<header; i++) {
          fgets (line1,1023,inputfile);
          fprintf (stderr,"%s",line1);
       }  
    
       InputFormat=0;
       fgets (line1,1023,inputfile);
       dummy=strtok(line1," ");
       while (dummy!=NULL) {
          InputFormat++;
          dummy=strtok(NULL," ");
       }
       if (InputFormat == 5) InputFormat =4;
   
       rewind(inputfile);
    }   
    
    for (i=0; i<header; i++) {
       fgets (line1,1023,inputfile);
    }
    
    if (InputFormat < 2 || InputFormat > 4) {
      fprintf (stderr,"Your data file has the wrong number of columns\n");
      exit(-1);
    }

    /* If InputFormat =3 or 4 assign values to color and open cpt file */
    
    if (InputFormat == 3 || InputFormat == 4) {

      assignColor (ColorSwitch,color);

      if (strlen(cptfileName) == 0) {
	sprintf(cptfileName,"%s.cpt",prefix);
      }
          
      cptfile= fopen (cptfileName, "w");
      fprintf (stderr,"\nI have opened the file %s\n",cptfileName);    
    }

    /* Find extrema */

    count=0;
    count2=0;
    if (InputFormat==2) {
      while (2==fscanf (inputfile, "%f%f", &x, &y)){
	count++;
	if (fabs(fabs(x)-fabs(nan)) > fabs(eps) && 
	    fabs(fabs(y)-fabs(nan)) > fabs(eps)) {
	  count2++;
	  if (count2==1) {
	    xmin=xmax=ymax_x=ymin_x=x;
	    ymin=ymax=y;
	  }
	  if (x > xmax) xmax=x;
	  if (x < xmin) xmin=x;
	  if (y > ymax) {
	    ymax=y;
	    ymax_x=x;
	  }
	  if (y < ymin) {
	    ymin=y;
	    ymin_x=x;
	  }
	}
      }
    }
    
    
    if (InputFormat ==3 || InputFormat == 4) {
      do {
	if (InputFormat == 3) {
	  EndOfFile=fscanf (inputfile,"%f%f%f", &x,&y,&z);
	  count++;
	}
	if (InputFormat == 4) {
	  EndOfFile=fscanf (inputfile,"%f%f%f%f", &w,&x,&y,&z);
	  count++;
	}
	if (EndOfFile!=-1) {
	  go=0;
	  if (checkz == 0) {
	    if ((fabs(fabs(x)-fabs(nan)) > fabs(eps)) && 
		(fabs(fabs(y)-fabs(nan)) > fabs(eps))) {
	      go = 1;
	    }
	  }
	  if (checkz == 1) {
	    if ((fabs(fabs(x)-fabs(nan)) > fabs(eps)) && 
		(fabs(fabs(y)-fabs(nan)) > fabs(eps)) &&
		(fabs(fabs(z)-fabs(nan)) > fabs(eps))  ) {
	      go = 1;
	    }
	  }
	  if (go == 1) {

	    count2++;
	    if (count2==1) {
	      xmin=xmax=zmin_x=x;
	      ymin=ymax=zmin_y=y;
	      zmin=zmax=z;
	    }
	    if (x > xmax) xmax=x;
	    if (x < xmin) xmin=x;
	    if (y > ymax) ymax=y;
	    if (y < ymin) ymin=y;
	    if (z > zmax) {
	      zmax=z;
	      zmax_x=x;
	      zmax_y=y;
	    }
	    if (z < zmin) {
	      zmin=z;
	      zmin_x=x;
	      zmin_y=y;
	    }
	  }      
	}
      } while (EndOfFile!=-1);
    }
  /* Write  on the info file */

    fprintf (infofile,"Name of the input file: %s\n\n",inputfileName);
    fprintf (infofile,"Number of columns in the input file: %d\n", InputFormat);
    fprintf (infofile,"Number of elements in the file     : %d\n",count-1);
    fprintf (infofile,"Number of elements used (!=nan)    : %d\n\n",count2);
    fprintf (infofile,"Extrema  Xmin,Xmax : %f %f\n",xmin,xmax);
    if (InputFormat == 2){
      fprintf (infofile,"           Ymin(x) : %f (%f)\n",ymin,ymin_x);
      fprintf (infofile,"           Ymax(x) : %f (%f)\n\n",ymax,ymax_x);
    }
    if (InputFormat == 3 || InputFormat == 4) {
    fprintf (infofile,"         Ymin,Ymax : %f %f\n",ymin,ymax);
      fprintf (infofile,"         Zmin(x,y) : %f (%f,%f)\n",
	       zmin,zmin_x,zmin_y);
      fprintf (infofile,"         Zmax(x,y) : %f (%f,%f)\n\n",
	       zmax,zmax_x,zmax_y);
    }

    fprintf (infofile,"Name of the GMT script file: %s\n",gmtfileName);
    fprintf (infofile,"Name of the PostScript file: %s\n\n",psfileName);
    if (InputFormat == 3 || InputFormat == 4) {
      fprintf (infofile,"%% of delta Z added/subtr. to/from z extrema: %f\n",
	       percent);
      fprintf (infofile,"Colour table used to construct .cpt file   : %d\n",
	       ColorSwitch);
      fprintf (infofile,"Name of the .cpt file                      : %s\n",
	       cptfileName);
      fprintf (infofile,"Precision in  the .cpt file                : %d\n\n",
	       prec);
      fprintf (infofile,"Plot created with                          : %s\n",
	       output_program);
    }

/*
  If we got 3D data (IN=3 or 4) then find the interval for the
  colours and write on the cpt file
  CHANGES: if you want to add a new color table, count the number
           of intervals (variable "parts")and change the following
           section
*/

    if (InputFormat == 3 || InputFormat == 4) {
      if (ColorSwitch == 1 || ColorSwitch == 2 || ColorSwitch == 6  || 
	  ColorSwitch == 10 || ColorSwitch == 13 || ColorSwitch == 14) parts=8;
      if (ColorSwitch == 3 || ColorSwitch == 4 || ColorSwitch == 11 || 
	  ColorSwitch == 12) parts=22;
      if (ColorSwitch == 5) parts=44;
      if (ColorSwitch == 7 || ColorSwitch == 8 || ColorSwitch == 9) parts=12;
      if (ColorSwitch == 15)  parts=4; 
      if (ColorSwitch > 15 || ColorSwitch <1 ) {
	fprintf (stderr, "\n Allowed values for is are 1-13!!!!\n");
	exit(-1);
      }
            
  /*
 We add IPROZ % of (zmax-zmin) to zmax and subtract it from zmin
 This gives a new deltaz, which is used to write the cpt file
 */

      dz_old=zmax-zmin;
      extra_z=percent/100.*dz_old;
      zmax+=extra_z;
      zmin-=extra_z;
      dz=zmax-zmin;
      z_interval=dz/parts;
      zmin_help=0.0;
      
      if (add == 1){
	sprintf (format,"%%20.%df %s  %%20.%df %s",
		 prec, "255 255 255", prec, "255 255 255\n");
	fprintf (cptfile, format, zmin_help, zmin);
      }

      for (i=1;i<=parts;i++){

	z1=zmin+(i-1)*z_interval;
	z2=zmin+i*z_interval;
	sprintf (format,"%%20.%df %s %%20.%df %s", prec, "%s %s %s ", prec, "%s %s %s\n");
        fprintf (cptfile, format, z1, color[i][1], color[i][2], color[i][3],
		 z2, color[i][1], color[i][2], color[i][3]);
      }
      fclose(cptfile);
    }

    /* Create and execute the gmt script */

    gmtplot
    (InputFormat,inputfileName,psfileName,cptfileName,gmtfileName,xmin,xmax,ymin,ymax,base,xsize,ysize,title,OutputFormat,header);

    if (RunGmt==1) {

      printf ("Executing \"%s\" ....\n", gmtfileName);

      if ( fork () == 0 )
	{
	  /* child */

	  printf ("\nExecution of %s failed with error code %d\n",
		  gmtfileName, execl (gmtfileName, gmtfileName, NULL));

	  exit (-1);
	}
      else
	{
	  /* parent */

	  wait (NULL);
	}

      /* exgmt (gmtfileName);*/
      /* system(gmtfileName);*/
    }
    
    exit (0);
}



/* Subroutine assignColor assigns colour values to the array COLOR
 according to the choosen color table 
 CHANGES: if you want to edit a new color table, add a new section
          if (ColorSwitch== number) 
*/


   void  assignColor (int ColorSwitch, char *color[50][3]) 

{

  /* Colour file col_8.cpt */

  if (ColorSwitch ==1){
    color[1][1] = "235";
    color[1][2] = "  0";
    color[1][3] = " 20";
    color[2][1] = "255";
    color[2][2] = "100";
    color[2][3] = " 65";
    color[3][1] = "255";
    color[3][2] = "200";
    color[3][3] = " 65";
    color[4][1] = "255";
    color[4][2] = "255";
    color[4][3] = "100";
    color[5][1] = "200";
    color[5][2] = "255";
    color[5][3] = "100";
    color[6][1] = "120";
    color[6][2] = "255";
    color[6][3] = "255";
    color[7][1] = " 65";
    color[7][2] = "190";
    color[7][3] = "255";
    color[8][1] = " 65";
    color[8][2] = " 96";
    color[8][3] = "255";
  }

/* Colour file gray_8.cpt */

  if (ColorSwitch == 2) {
    color[1][1] = "240";
    color[1][2] = "240";
    color[1][3] = "240";
    color[2][1] = "208";
    color[2][2] = "208";
    color[2][3] = "208";
    color[3][1] = "176";
    color[3][2] = "176";
    color[3][3] = "176";
    color[4][1] = "144";
    color[4][2] = "144";
    color[4][3] = "144";
    color[5][1] = "112";
    color[5][2] = "112";
    color[5][3] = "112";
    color[6][1] = " 80";
    color[6][2] = " 80";
    color[6][3] = " 80";
    color[7][1] = " 48";
    color[7][2] = " 48";
    color[7][3] = " 48";
    color[8][1] = "  0";
    color[8][2] = "  0";
    color[8][3] = "  0";
  }

  /* Colour file GGT_a.cpt */

  if (ColorSwitch == 3) {
    color[1][1]  = " 96";
    color[1][2]  = " 32";
    color[1][3]  = "  0";
    color[2][1]  = "128";
    color[2][2]  = " 32";
    color[2][3]  = "  0";
    color[3][1]  = "128";
    color[3][2]  = " 64";
    color[3][3]  = " 32";
    color[4][1]  = "128";
    color[4][2]  = " 64";
    color[4][3]  = " 64";
    color[5][1]  = "128";
    color[5][2]  = " 64";
    color[5][3]  = "128";
    color[6][1]  = "128";
    color[6][2]  = " 32";
    color[6][3]  = "128";
    color[7][1]  = "128";
    color[7][2]  = " 32";
    color[7][3]  = "160";
    color[8][1]  = "128";
    color[8][2]  = " 32";
    color[8][3]  = "192";
    color[9][1]  = "128";
    color[9][2]  = " 32";
    color[9][3]  = "255";
    color[10][1] = " 96";
    color[10][2] = " 64";
    color[10][3] = "255";
    color[11][1] = " 64";
    color[11][2] = " 96";
    color[11][3] = "255";
    color[12][1] = " 32";
    color[12][2] = "128";
    color[12][3] = "255";
    color[13][1] = "  0";
    color[13][2] = "160";
    color[13][3] = "255";
    color[14][1] = "  0";
    color[14][2] = "192";
    color[14][3] = "255";
    color[15][1] = "  0";
    color[15][2] = "224";
    color[15][3] = "255";
    color[16][1] = "  0";
    color[16][2] = "255";
    color[16][3] = "255";
    color[17][1] = "  0";
    color[17][2] = "255";
    color[17][3] = "224";
    color[18][1] = "  0";
    color[18][2] = "255";
    color[18][3] = "192";
    color[19][1] = "  0";
    color[19][2] = "255";
    color[19][3] = "160";
    color[20][1] = "  0";
    color[20][2] = "255";
    color[20][3] = "128";
    color[21][1] = "  0";
    color[21][2] = "255";
    color[21][3] = " 96";
    color[22][1] = "  0";
    color[22][2] = "255";
    color[22][3] = " 32";
  }

  /* Colour file GGT_b.cpt */

  if (ColorSwitch == 4){
    color[1][1]  = " 32";
    color[1][2]  = "255";
    color[1][3]  = " 32";
    color[2][1]  = " 64";
    color[2][2]  = "255";
    color[2][3]  = " 32";
    color[3][1]  = " 96";
    color[3][2]  = "255";
    color[3][3]  = " 32";
    color[4][1]  = "128";
    color[4][2]  = "255";
    color[4][3]  = " 32";
    color[5][1]  = "160";
    color[5][2]  = "255";
    color[5][3]  = " 32";
    color[6][1]  = "192";
    color[6][2]  = "255";
    color[6][3]  = " 32";
    color[7][1]  = "224";
    color[7][2]  = "255";
    color[7][3]  = " 32";
    color[8][1]  = "255";
    color[8][2]  = "255";
    color[8][3]  = " 32";
    color[9][1]  = "255";
    color[9][2]  = "224";
    color[9][3]  = " 32";
    color[10][1] = "255";
    color[10][2] = "192";
    color[10][3] = " 32";
    color[11][1] = "225";
    color[11][2] = "160";
    color[11][3] = " 32";
    color[12][1] = "225";
    color[12][2] = "128";
    color[12][3] = " 32";
    color[13][1] = "255";
    color[13][2] = " 96";
    color[13][3] = " 32";
    color[14][1] = "255";
    color[14][2] = " 64";
    color[14][3] = " 64";
    color[15][1] = "225";
    color[15][2] = "032";
    color[15][3] = " 64";
    color[16][1] = "225";
    color[16][2] = "  0";
    color[16][3] = "128";
    color[17][1] = "255";
    color[17][2] = " 32";
    color[17][3] = "128";
    color[18][1] = "255";
    color[18][2] = " 32";
    color[18][3] = "192";
    color[19][1] = "255";
    color[19][2] = " 32";
    color[19][3] = "255";
    color[20][1] = "224";
    color[20][2] = "  0";
    color[20][3] = "255";
    color[21][1] = "192";
    color[21][2] = "  0";
    color[21][3] = "224";
    color[22][1] = "160";
    color[22][2] = "  0";
    color[22][3] = "160";
  }

  /* Colour file GGT_a + GGT_b */

  if (ColorSwitch == 5) {
    color[1][1]  = " 96";
    color[1][2]  = " 32";
    color[1][3]  = "  0";
    color[2][1]  = "128";
    color[2][2]  = " 32";
    color[2][3]  = "  0";
    color[3][1]  = "128";
    color[3][2]  = " 64";
    color[3][3]  = " 32";
    color[4][1]  = "128";
    color[4][2]  = " 64";
    color[4][3]  = " 64";
    color[5][1]  = "128";
    color[5][2]  = " 64";
    color[5][3]  = "128";
    color[6][1]  = "128";
    color[6][2]  = " 32";
    color[6][3]  = "128";
    color[7][1]  = "128";
    color[7][2]  = " 32";
    color[7][3]  = "160";
    color[8][1]  = "128";
    color[8][2]  = " 32";
    color[8][3]  = "192";
    color[9][1]  = "128";
    color[9][2]  = " 32";
    color[9][3]  = "255";
    color[10][1] = " 96";
    color[10][2] = " 64";
    color[10][3] = "255";
    color[11][1] = " 64";
    color[11][2] = " 96";
    color[11][3] = "255";
    color[12][1] = " 32";
    color[12][2] = "128";
    color[12][3] = "255";
    color[13][1] = "  0";
    color[13][2] = "160";
    color[13][3] = "255";
    color[14][1] = "  0";
    color[14][2] = "192";
    color[14][3] = "255";
    color[15][1] = "  0";
    color[15][2] = "224";
    color[15][3] = "255";
    color[16][1] = "  0";
    color[16][2] = "255";
    color[16][3] = "255";
    color[17][1] = "  0";
    color[17][2] = "255";
    color[17][3] = "224";
    color[18][1] = "  0";
    color[18][2] = "255";
    color[18][3] = "192";
    color[19][1] = "  0";
    color[19][2] = "255";
    color[19][3] = "160";
    color[20][1] = "  0";
    color[20][2] = "255";
    color[20][3] = "128";
    color[21][1] = "  0";
    color[21][2] = "255";
    color[21][3] = " 96";
    color[22][1] = "  0";
    color[22][2] = "255";
    color[22][3] = " 32";
    color[23][1] = " 32";
    color[23][2] = "255";
    color[23][3] = " 32";
    color[24][1] = " 64";
    color[24][2] = "255";
    color[24][3] = " 32";
    color[25][1] = " 96";
    color[25][2] = "255";
    color[25][3] = " 32";
    color[26][1] = "128";
    color[26][2] = "255";
    color[26][3] = " 32";
    color[27][1] = "160";
    color[27][2] = "255";
    color[27][3] = " 32";
    color[28][1] = "192";
    color[28][2] = "255";
    color[28][3] = " 32";
    color[29][1] = "224";
    color[29][2] = "255";
    color[29][3] = " 32";
    color[30][1] = "255";
    color[30][2] = "255";
    color[30][3] = " 32";
    color[31][1] = "255";
    color[31][2] = "224";
    color[31][3] = " 32";
    color[32][1] = "255";
    color[32][2] = "192";
    color[32][3] = " 32";
    color[33][1] = "225";
    color[33][2] = "160";
    color[33][3] = " 32";
    color[34][1] = "225";
    color[34][2] = "128";
    color[34][3] = " 32";
    color[35][1] = "255";
    color[35][2] = "096";
    color[35][3] = " 32";
    color[36][1] = "255";
    color[36][2] = " 64";
    color[36][3] = " 64";
    color[37][1] = "225";
    color[37][2] = " 32";
    color[37][3] = " 64";
    color[38][1] = "225";
    color[38][2] = "  0";
    color[38][3] = "128";
    color[39][1] = "255";
    color[39][2] = " 32";
    color[39][3] = "128";
    color[40][1] = "255";
    color[40][2] = " 32";
    color[40][3] = "192";
    color[41][1] = "255";
    color[41][2] = " 32";
    color[41][3] = "255";
    color[42][1] = "224";
    color[42][2] = "  0";
    color[42][3] = "255";
    color[43][1] = "192";
    color[43][2] = "  0";
    color[43][3] = "224";
    color[44][1] = "160";
    color[44][2] = "  0";
    color[44][3] = "160";
  }

  /* Colour file topo_8.cpt */

  if (ColorSwitch ==6) {
    color[1][1] = "224";
    color[1][2] = "255";
    color[1][3] = " 32";
    color[2][1] = "255";
    color[2][2] = "255";
    color[2][3] = " 32";
    color[3][1] = "255";
    color[3][2] = "224";
    color[3][3] = " 32";
    color[4][1] = "255";
    color[4][2] = "160";
    color[4][3] = " 32";
    color[5][1] = "255";
    color[5][2] = " 96";
    color[5][3] = " 32";
    color[6][1] = "255";
    color[6][2] = " 32";
    color[6][3] = " 64";
    color[7][1] = " 96";
    color[7][2] = " 32";
    color[7][3] = "  0";
    color[8][1] = "128";
    color[8][2] = " 64";
    color[8][3] = " 32";
  }

  /* Colour file topo_12.cpt */

  if (ColorSwitch == 7) {
    color[1][1]  = "  0";
    color[1][2]  = "255";
    color[1][3]  = "255";
    color[2][1]  = "  0";
    color[2][2]  = "255";
    color[2][3]  = "224";
    color[3][1]  = "224";
    color[3][2]  = "255";
    color[3][3]  = " 32";
    color[4][1]  = "255";
    color[4][2]  = "255";
    color[4][3]  = " 32";
    color[5][1]  = "255";
    color[5][2]  = "224";
    color[5][3]  = " 32";
    color[6][1]  = "255";
    color[6][2]  = "160";
    color[6][3]  = " 32";
    color[7][1]  = "255";
    color[7][2]  = " 96";
    color[7][3]  = " 32";
    color[8][1]  = "255";
    color[8][2]  = " 32";
    color[8][3]  = " 32";
    color[9][1]  = "200";
    color[9][2]  = " 32";
    color[9][3]  = " 32";
    color[10][1] = "128";
    color[10][2] = " 64";
    color[10][3] = " 64";
    color[11][1] = "128";
    color[11][2] = "100";
    color[11][3] = "100";
    color[12][1] = "128";
    color[12][2] = "128";
    color[12][3] = "128";
  }

  /* Colour file topo_12a.cpt */

  if (ColorSwitch == 8) {
    color[1][1]  = "  0";
    color[1][2]  = "255";
    color[1][3]  = "224";
    color[2][1]  = "128";
    color[2][2]  = "255";
    color[2][3]  = " 32";
    color[3][1]  = "224";
    color[3][2]  = "255";
    color[3][3]  = " 32";
    color[4][1]  = "255";
    color[4][2]  = "255";
    color[4][3]  = " 32";
    color[5][1]  = "255";
    color[5][2]  = "224";
    color[5][3]  = " 32";
    color[6][1]  = "255";
    color[6][2]  = "160";
    color[6][3]  = " 32";
    color[7][1]  = "255";
    color[7][2]  = " 96";
    color[7][3]  = " 32";
    color[8][1]  = "255";
    color[8][2]  = " 32";
    color[8][3]  = " 32";
    color[9][1]  = "200";
    color[9][2]  = " 32";
    color[9][3]  = " 32";
    color[10][1] = "128";
    color[10][2] = " 64";
    color[10][3] = " 64";
    color[11][1] = "128";
    color[11][2] = "100";
    color[11][3] = "100";
    color[12][1] = "156";
    color[12][2] = "140";
    color[12][3] = "140";
  }

  /* Colour file topo_12b.cpt */

  if (ColorSwitch == 9) {
    color[1][1]  = "175";
    color[1][2]  = "254";
    color[1][3]  = "245";
    color[2][1]  = "183";
    color[2][2]  = "254";
    color[2][3]  = "129";
    color[3][1]  = "237";
    color[3][2]  = "254";
    color[3][3]  = "129";
    color[4][1]  = "254";
    color[4][2]  = "254";
    color[4][3]  = "129";
    color[5][1]  = "254";
    color[5][2]  = "237";
    color[5][3]  = "129";
    color[6][1]  = "254";
    color[6][2]  = "201";
    color[6][3]  = "129";
    color[7][1]  = "254";
    color[7][2]  = "165";
    color[7][3]  = "129";
    color[8][1]  = "254";
    color[8][2]  = "129";
    color[8][3]  = "129";
    color[9][1]  = "224";
    color[9][2]  = "129";
    color[9][3]  = "129";
    color[10][1] = "183";
    color[10][2] = "147";
    color[10][3] = "147";
    color[11][1] = "183";
    color[11][2] = "168";
    color[11][3] = "168";
    color[12][1] = "210";
    color[12][2] = "200";
    color[12][3] = "200";
  }

  /* Some other file */

  if (ColorSwitch == 10) {
    color[8][1]  = "235";
    color[8][2]  = "  0";
    color[8][3]  = " 20";
    color[7][1]  = "255";
    color[7][2]  = "100";
    color[7][3]  = " 65";
    color[6][1]  = "255";
    color[6][2]  = "200";
    color[6][3]  = " 65";
    color[5][1]  = "255";
    color[5][2]  = "255";
    color[5][3]  = "100";
    color[4][1]  = "200";
    color[4][2]  = "255";
    color[4][3]  = "100";
    color[3][1]  = "120";
    color[3][2]  = "255";
    color[3][3]  = "255";
    color[2][1]  = " 65";
    color[2][2]  = "190";
    color[2][3]  = "255";
    color[1][1]  = " 65";
    color[1][2]  = " 96";
    color[1][3]  = "255";
  }

  /* Start: ggt_a purple] end ggt_b: yellow */

  if (ColorSwitch == 11) {
    color[1][1]  = "128";
    color[1][2]  = " 32";
    color[1][3]  = "255";
    color[2][1]  = " 96";
    color[2][2]  = " 64";
    color[2][3]  = "255";
    color[3][1]  = " 64";
    color[3][2]  = " 96";
    color[3][3]  = "255";
    color[4][1]  = " 32";
    color[4][2]  = "128";
    color[4][3]  = "255";
    color[5][1]  = "  0";
    color[5][2]  = "160";
    color[5][3]  = "255";
    color[6][1]  = "  0";
    color[6][2]  = "192";
    color[6][3]  = "255";
    color[7][1]  = "  0";
    color[7][2]  = "224";
    color[7][3]  = "255";
    color[8][1]  = "  0";
    color[8][2]  = "255";
    color[8][3]  = "255";
    color[9][1]  = "  0";
    color[9][2]  = "255";
    color[9][3]  = "224";
    color[10][1] = "  0";
    color[10][2] = "255";
    color[10][3] = "192";
    color[11][1] = "  0";
    color[11][2] = "255";
    color[11][3] = "160";
    color[12][1] = "  0";
    color[12][2] = "255";
    color[12][3] = "128";
    color[13][1] = "  0";
    color[13][2] = "255";
    color[13][3] = " 96";
    color[14][1] = "  0";
    color[14][2] = "255";
    color[14][3] = " 32";
    color[15][1] = " 32";
    color[15][2] = "255";
    color[15][3] = " 32";
    color[16][1] = " 64";
    color[16][2] = "255";
    color[16][3] = " 32";
    color[17][1] = " 96";
    color[17][2] = "255";
    color[17][3] = " 32";
    color[18][1] = "128";
    color[18][2] = "255";
    color[18][3] = " 32";
    color[19][1] = "160";
    color[19][2] = "255";
    color[19][3] = " 32";
    color[20][1] = "192";
    color[20][2] = "255";
    color[20][3] = " 32";
    color[21][1] = "224";
    color[21][2] = "255";
    color[21][3] = " 32";
    color[22][1] = "255";
    color[22][2] = "255";
    color[22][3] = " 32";
  }

  /* Same as 11 but Start: ggt_b yellow] end ggt_a: purple */

  if (ColorSwitch == 12) {
    color[22][1]  = "128";
    color[22][2]  = " 32";
    color[22][3]  = "255";
    color[21][1]  = " 96";
    color[21][2]  = " 64";
    color[21][3]  = "255";
    color[20][1]  = " 64";
    color[20][2]  = " 96";
    color[20][3]  = "255";
    color[19][1]  = " 32";
    color[19][2]  = "128";
    color[19][3]  = "255";
    color[18][1]  = "  0";
    color[18][2]  = "160";
    color[18][3]  = "255";
    color[17][1]  = "  0";
    color[17][2]  = "192";
    color[17][3]  = "255";
    color[16][1]  = "  0";
    color[16][2]  = "224";
    color[16][3]  = "255";
    color[15][1]  = "  0";
    color[15][2]  = "255";
    color[15][3]  = "255";
    color[14][1]  = "  0";
    color[14][2]  = "255";
    color[14][3]  = "224";
    color[13][1]  = "  0";
    color[13][2]  = "255";
    color[13][3]  = "192";
    color[12][1]  = "  0";
    color[12][2]  = "255";
    color[12][3]  = "160";
    color[11][1]  = "  0";
    color[11][2]  = "255";
    color[11][3]  = "128";
    color[10][1]  = "  0";
    color[10][2]  = "255";
    color[10][3]  = " 96";
    color[9][1]   = "  0";
    color[9][2]   = "255";
    color[9][3]   = " 32";
    color[8][1]   = " 32";
    color[8][2]   = "255";
    color[8][3]   = " 32";
    color[7][1]   = " 64";
    color[7][2]   = "255";
    color[7][3]   = " 32";
    color[6][1]   = " 96";
    color[6][2]   = "255";
    color[6][3]   = " 32";
    color[5][1]   = "128";
    color[5][2]   = "255";
    color[5][3]   = " 32";
    color[4][1]   = "160";
    color[4][2]   = "255";
    color[4][3]   = " 32";
    color[3][1]   = "192";
    color[3][2]   = "255";
    color[3][3]   = " 32";
    color[2][1]   = "224";
    color[2][2]   = "255";
    color[2][3]   = " 32";
    color[1][1]   = "255";
    color[1][2]   = "255";
    color[1][3]   = " 32";
  }  
  
/* A color bar which gives the same result as is =2 (black-white) if
 * printed on a non-colour printer */

  if (ColorSwitch == 13) {
    color[8][1]  = "  0";
    color[8][2]  = "  0";
    color[8][3]  = "  0";
    color[7][1]  = " 96";
    color[7][2]  = " 32";
    color[7][3]  = "  0";
    color[6][1]  = "128";
    color[6][2]  = " 32";
    color[6][3]  = "255";
    color[5][1]  = " 32";
    color[5][2]  = "128";
    color[5][3]  = "255";
    color[4][1]  = "  0";
    color[4][2]  = "192";
    color[4][3]  = "255";
    color[3][1]  = "  0";
    color[3][2]  = "255";
    color[3][3]  = " 96";
    color[2][1]   = "160";
    color[2][2]   = "255";
    color[2][3]   = " 32"; 
/*    color[2][1]   = "192";
    color[2][2]   = "255";
    color[2][3]   = " 32"; */
    color[1][1]   = "255";
    color[1][2]   = "255";
    color[1][3]   = " 32";
  }
/* A color bar which gives the same result as is =2 (black-white) if
 * printed on a non-colour printer */

  if (ColorSwitch == 14) {
    color[1][1]   = "255";
    color[1][2]   = "255";
    color[1][3]   = " 32";
    color[2][1]   = "255";
    color[2][2]   = "224";
    color[2][3]   = " 32";
    color[3][1]  = "255";
    color[3][2]  = "160";
    color[3][3]  = " 32";
    color[4][1]  = "255";
    color[4][2]  = " 96";
    color[4][3]  = " 32";
    color[5][1]  = "255";
    color[5][2]  = " 32";
    color[5][3]  = " 32";
    color[6][1]  = "200";
    color[6][2]  = " 32";
    color[6][3]  = " 32";
    color[7][1]  = " 96";
    color[7][2]  = " 32";
    color[7][3]  = "  0";
    color[8][1]  = "  0";
    color[8][2]  = "  0";
    color[8][3]  = "  0";
  }


/* Colour file gray_4.cpt */

  if (ColorSwitch == 15) {
    color[1][1] = "240";
    color[1][2] = "240";
    color[1][3] = "240";
    color[2][1] = "160";
    color[2][2] = "160";
    color[2][3] = "160";
    color[3][3] = " 80";
    color[3][1] = " 80";
    color[3][2] = " 80";
    color[4][1] = "  0";
    color[4][2] = "  0";
    color[4][3] = "  0";
  }
  return;
}


void	gmtplot   ( int         InputFormat,   /* Switch for input data*/
                    char	*inputfileName,	/* extracted xy data	 */
		    char	*psfileName,	/* final postscript file */
		    char        *cptfileName,   /* gmt colour file */
		    char	*gmtfileName,	/* temporary script file */
		    float	x_min,		/**/
		    float	x_max,		/**/
		    float	y_min,	        /**/
		    float	y_max,	        /**/
		    float       base,           /* percentage to extend the basemap */
		    float       xsize,
		    float       ysize,
		    char        *title,
		    int         OutputFormat,
		    int         header)

{ FILE		*gmtfile;

  float		xoffset,yoffset,xgrid,ygrid;
  float         x_scale,y_scale,height_scale,width_scale;
  float         xtick,xannot,ytick,yannot;
  float         x_base,y_base;
  float         search_x,search_y;
  float         search_radius;
  float         point_size;

  char		*command,*xtitle,*ytitle,*gridfile;

  /* Assign some initial values */

    xoffset=1.8;
    yoffset=1.5;
    xtitle="X-axis";
    ytitle="Y-axis";
    gridfile="grdfile.grd";
    x_scale=xsize+1.0;
    y_scale=2.5;
    height_scale=5.0;
    width_scale=0.5;


  /* Open script file */

    if (gmtfileName == NULL) {
      gmtfile=stdout;
    }
    else {
      gmtfile= fopen (gmtfileName, "w");
      fprintf (stderr,"\nI have opened the file %s\n",gmtfileName);
    }

 /* Write script file */ 

    fprintf (gmtfile, "%s", "#!/bin/sh\n");
    /* fprintf (gmtfile, "%s", "set -x\n");*/
    fprintf (gmtfile, "%s", "#\n");
    fprintf (gmtfile, "echo \"Creating the basemap\"\n");
    
    x_base = (x_max - x_min) * base/100.;
    y_base = (y_max - y_min) * base/100.;
    x_min = x_min - x_base;
    x_max = x_max + x_base;
    y_min = y_min - y_base;
    y_max = y_max + y_base;

    xtick = (x_max - x_min)/5.;
    xannot = xtick;
    ytick = (y_max - y_min)/5.;
    yannot = ytick;

    search_x=fabs(x_min)+fabs(x_max);
    search_y=fabs(y_min)+fabs(y_max);

    if (search_x < search_y) search_radius=search_y/5;
    else search_radius=search_x/5;

    point_size=xsize/60.;
	      
    if (InputFormat == 2 ) {

      fprintf (gmtfile, "echo \"Creating the yx-plot ....\"\n");
      command= "psxy %s -K -JX%g/%g -R%g/%g/%g/%g -W2/255/0/0 -H%d -X%g -Y%g > %s\n";
      fprintf (gmtfile, command, inputfileName,
	       xsize, ysize, x_min, x_max,
	       y_min, y_max, header, xoffset, yoffset,
	       psfileName);

      command= "psbasemap -O -JX%g/%g -R%g/%g/%g/%g -Bf%ga%g:\"%s\":/f%ga%g:\"%s\"::.\"%s\":WeSn >> %s\n";
 	
      fprintf (gmtfile, command,
	       xsize, ysize, x_min, x_max, y_min, y_max,
	       xtick, xannot, xtitle, ytick, yannot, ytitle,
	       title, psfileName);
    }

      /* Grid the data */

    if (InputFormat == 3) {
      
      if (OutputFormat == 0) {

	fprintf (gmtfile, "echo \"Running the grid ....\"\n");
	command= "nearneighbor %s -G%s -I%g/%g -R%g/%g/%g/%g -N1 -S%g\n";
	xgrid = (x_max - x_min - 2.*x_base)/20.;
	ygrid = (y_max - y_min - 2.*y_base)/20.;
      
	fprintf (gmtfile, command, inputfileName,gridfile,
		 xgrid,ygrid,x_min+x_base, x_max-x_base,
		 y_min+y_base, y_max-y_base,
		 search_radius);
      }
    }

    if (InputFormat == 4) {

      if (OutputFormat == 0) {
      
	fprintf (gmtfile, "echo \"Running the grid ....\"\n");

	command= "awk \'{printf(\"%%20.10f %%20.10f %%20.10f \\n\",\0442,\0443,\0444)}\' %s \174 ";
	fprintf (gmtfile, command, inputfileName);
	
	xgrid = (x_max - x_min - 2.*x_base)/20.;
	ygrid = (y_max - y_min - 2.*y_base)/20.;
	command= "nearneighbor  -G%s -I%g/%g -R%g/%g/%g/%g -N1 -S%g\n";
	fprintf (gmtfile, command, gridfile,
		 xgrid,ygrid,x_min+x_base, x_max-x_base,
		 y_min+y_base, y_max-y_base,
		 search_radius);
      }
    }

      /* Execute grdview to plot the data */

    if (InputFormat ==3 || InputFormat ==4) {

      if (OutputFormat == 0 ) {
	fprintf (gmtfile, "echo \"Creating the xyz plot ....\"\n");

	command= "grdview  %s -K -JX%g/%g -R%g/%g/%g/%g -C%s -Qs  -D3 -X%g -Y%g > %s\n";
	fprintf (gmtfile, command, gridfile, 
		 xsize, ysize, x_min, x_max, y_min, y_max,
		 cptfileName, xoffset, yoffset, psfileName);
      }

      if (OutputFormat == 1) {
	if (InputFormat == 3) {
	  command= "psxy  %s -K -JX%g/%g -R%g/%g/%g/%g -C%s -Sc%g -X%g -Y%g > %s\n";
	  fprintf (gmtfile, command, inputfileName, 
		   xsize, ysize, x_min, x_max, y_min, y_max,
		   cptfileName, point_size, xoffset, yoffset, psfileName);
	  
	}
	
	if (InputFormat == 4) {
	  command= "awk \'{printf(\"%%20.10f %%20.10f %%20.10f \\n\",\0442,\0443,\0444)}\' %s \174 ";
	  fprintf (gmtfile, command, inputfileName);	

	  command= "psxy  -K -JX%g/%g -R%g/%g/%g/%g -C%s -Sc%g -X%g -Y%g > %s\n";
	  fprintf (gmtfile, command,  
		   xsize, ysize, x_min, x_max, y_min, y_max,
		   cptfileName, point_size, xoffset, yoffset, psfileName);  
	
	}

      }


      command= "psbasemap -O -K -JX%g/%g -R%g/%g/%g/%g -Bf%ga%g:\"%s\":/f%ga%g:\"%s\"::.\"%s\":WeSn >> %s\n";
      fprintf (gmtfile, command,
	       xsize, ysize, x_min, x_max, y_min, y_max,
	       xtick, xannot, xtitle, ytick, yannot, ytitle,
	       title, psfileName);

      /* Execute psscale to plot a colour scale*/

      fprintf (gmtfile, "echo \"Creating the scale ....\"\n");

      command ="psscale -C%s -D%g/%g/%g/%g -L -O >> %s\n";
      fprintf (gmtfile, command,
	       cptfileName, x_scale, y_scale, height_scale, width_scale,
	       psfileName);

    }

    /* View the PostScriptfile with ghostview */

    command="ghostview -a4 %s &\n";
    fprintf (gmtfile,command,psfileName);

    fprintf (gmtfile, "echo \"Done\"\n");

    fclose (gmtfile);

    chmod (gmtfileName, S_IRWXU);

    return;
}


void exgmt (char *gmtfileName)

{ char **argv;
  int	i;

	argv= (char **) malloc (2 * sizeof (char *));

      	for (i= 0; i < (int) strlen (gmtfileName); i++)
	  {
	    if (gmtfileName[i] == ' ') gmtfileName[i]= (char) 0;
	  }

	strcpy (argv[0], gmtfileName);
	argv[1]= NULL; 

	printf ("Executing \"%s\" ....\n", gmtfileName);

	if ( fork () == 0 )
	  {
	    /* child */

	    printf ("\nExecution of %s failed with error code %d\n",
		    gmtfileName, execl (gmtfileName, gmtfileName, NULL));

	    exit (-1);
	  }
	else
	  {
	    /* parent */

	    wait (NULL);
	  }

	free (argv);

	return;
}




