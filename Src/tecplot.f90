SUBROUTINE TECPLOT
  USE GLOBAL
  IMPLICIT NONE
  INTEGER::COUNTER
  REAL::UPVEL,DNVEL,ATVEL,VEL1,VEL2,VEL3,VEL4,VEL5,VEL6,VEL7,VEL8,VEL9, &
  VEL10,VEL11,VEL12,VEL13,VEL14,VEL15,VEL16,VEL17,VEL18,VEL19,VEL20
  INTEGER::I,J,L,LE,K,ITEMPMSK,ILL
  INTEGER::ICOUNT(TCOUNT,3)
  REAL::UTMPS,VTMPS,UTMP,VTMP
  REAL::MAG,MCHANGE
  REAL,DIMENSION(5)::MB
  REAL,DIMENSION(TCOUNT,2)::ESTORAGE
  REAL,DIMENSION(LC)::AVGSED
  REAL,DIMENSION(KC)::CTEMP1
  REAL,DIMENSION(IC-4)::MAGREF1,MAGREF2
  REAL :: LOCALVOL
  REAL :: RHOw, HTCAP, HTCONT, HTEMP							!VB HEAT CONTENT VARIABLES
  REAL :: WQV2, WQV3, WQV19, WQV22, WQVTEMP,WQV16,WQV17, WQV6, TIMESTEP			!VB TEMPORARY VARIABLES FOR TIMESERIES O/P
  REAL :: WTEMP, WVOL, VOLTEMP, WTMP, WQV10, WQV14, WQV15
  REAL :: WQV23,IlimMac,TlimMac,NlimMac,PlimMac,MacGro !Macroalgae
  REAL :: VELPDF !velocity PDF variable for ocean model
  REAL,SAVE::ELAST,TLAST
  INTEGER,SAVE::nstep
  LOGICAL,SAVE::FIRSTTIME=.FALSE. !,VERIFICATION=.TRUE.
!  LOGICAL::PDF=.FALSE.
  INTEGER::LL1,LL2
  REAL,DIMENSION(IC,JC)::PUPSTREAM,PDNSTREAM,PUPKIN,PDNKIN,PUPPOT,PDNPOT,DELTA
  REAL,DIMENSION(:,:,:),ALLOCATABLE::MDOTU,MDOTD
  REAL,DIMENSION(IC)::PUP,PDN,KUP,KDN,PPUP,PPDN
  CHARACTER(LEN=66)::timeline
  timeline='TEXT X=9, Y=84, T="&(ZONENAME[0001])", F=TIMES, CS=FRAME, H=3, ZN='
  IF(.NOT.FIRSTTIME)THEN
! This opens the Tecplot output file
    IF(MAXVAL(MVEGL(2:LA))>90)THEN !MHK devices exist
      OPEN(UNIT=222,FILE='powerout.dat')
      ITEMPMSK=1
      DO ILL=2,LA
        IF(MVEGL(ILL)>90)THEN
          ICOUNT(ITEMPMSK,1)=ITEMPMSK
          ICOUNT(ITEMPMSK,2)=IL(ILL)
          ICOUNT(ITEMPMSK,3)=JL(ILL)
          ITEMPMSK=ITEMPMSK+1
        ENDIF
      ENDDO
	  WRITE(222,'("TURBINE",100(I6,6X))')(ICOUNT(ILL,1),ILL=1,TCOUNT)
	  WRITE(222,'(7X,100(3X,I3,3X,I3))') (ICOUNT(ILL,2),ICOUNT(ILL,3),ILL=1,TCOUNT)
    ENDIF
	OPEN (UNIT=111,FILE='tecplot2d.dat')
    IF(IDNOTRVA/=0)THEN !Macroalgae output
      WRITE(111,'(A42)')'TITLE = "EFDC 2D Tecplot Macroalgae Data"'
	  WRITE(111,'(A81)')'VARIABLES="X","Y","U","V","MAC(kg/m^3)","Temp","Ilim","Tlim","Nlim","Plim","Grow"'!,"DO(g)","CO2(g)"' !,"HEAT(kJ)","VOL(M3)"'
      OPEN(112,FILE="2Dtransient.dat")
      WRITE(112,*)"Time, MAC, Light, Temp, P4D, NHX, NOX"
    ELSEIF(ISTRAN(8)==1)THEN !WQ data
	  WRITE(111,'(A36)')'TITLE = "EFDC 2D Tecplot Algae Data"'
	  WRITE(111,'(A77)')'VARIABLES="X","Y","U","V","SPEED","CHG(g)","P4D","NHX","NOX","DO(g)","CO2(g)"' !,"HEAT(kJ)","VOL(M3)"'
      OPEN(112,FILE="2Dtransient.dat")
      WRITE(112,*)"Time, Temp, CHG, O2, CO2, P4D, NHX, NOX"
    ELSEIF(IWRSP(1)==98)THEN !SEDZLJ data
      WRITE(111,*)'TITLE = "EFDC 2D Tecplot Sediment Data"'
      WRITE(111,*)'VARIABLES = "I","J","X","Y","TAU","D50","CBL","SED","U","V","THICK1","SPEED"'
      OPEN (UNIT = 112,FILE = 'massbal.dat')
      WRITE(112,*)'TITLE = "EFDC Mass Balance Data"'
      WRITE(112,*)'VARIABLES = "Time","MB1","MB2","MB3","MB4","MB5","ERATE","D50"'
    ELSE !Flow data
	  WRITE(111,'(A36)')'TITLE = "EFDC 2D Tecplot Flow Data"'
	  WRITE(111,'(A77)')'VARIABLES="X","Y","U","V","SPEED","SHEAR","DEPTH"' !,"HEAT(kJ)","VOL(M3)"'
	ENDIF
	IF(OUTPUTFLAG==4)THEN   ! IFREMER flume
	  OPEN(444,FILE='CALIBRATION.DAT')
	  WRITE(444,'("TIME        VEL3    VEL4    VEL5    VEL6    VEL7    VEL8    VEL9    VEL10   VEL11   VEL14")')
	ELSEIF(OUTPUTFLAG==5)THEN   ! Chilworth flume
	  OPEN(444,FILE='CALIBRATION.DAT')
	  WRITE(444,'("TIME        VEL3    VEL4    VEL5    VEL6    VEL7    VEL9    VEL11   VEL13   VEL15   VEL17   VEL20")')
	ELSEIF(OUTPUTFLAG==6)THEN   ! SAFL flume
	  OPEN(444,FILE='CALIBRATION.DAT')
	  WRITE(444,'("TIME        VEL1    VEL2    VEL3    VEL4    VEL5    VEL6    VEL7    VEL8    VEL9    VEL10  &
           VEL11   VEL12   VEL13   VEL14   VEL15   VEL16   VEL17   VEL18   VEL19   VEL20")')
	ELSEIF(OUTPUTFLAG==10)THEN   ! IFREMER flume
	  OPEN(444,FILE='CALIBRATION.DAT')
	  WRITE(444,'("TIME        +4      +3      +2      +1.33   +1      +0.67   +0.33   0.0     -0.33   -0.67   -1 &
           -1.33   -2      -3      -4")')
	ELSEIF(OUTPUTFLAG==3)THEN
	  OPEN(864,FILE='TIDALREF.DAT')
	  WRITE(864,'("3 ROWS OF AVERAGE VELOCITY, TOP VELOCITY, AND DEPTH")')
	ELSEIF(OUTPUTFLAG==2)THEN
      OPEN(468,FILE='VELPDF.DAT')
      WRITE(468,'("TIME AVERAGE VELOCITY ACROSS NARROWS I=60?")')
      OPEN(579,FILE='ZPROF.DAT')
	  WRITE(579,'("TIME VELOCITIES FOR EACH LAYER FOR PROFILES")')
	ELSEIF(OUTPUTFLAG==1)THEN
	  OPEN(765,FILE='POWERDIF.DAT')
	  WRITE(765,'("TIME   POWER DIFFERENCES ACROSS DIFFERENT I-CELL COLUMNS")')
	  OPEN(567,FILE='POTENTIAL.DAT')
	  WRITE(567,'("TIME   POTENTIAL DIFFERENCES ACROSS DIFFERENT I-CELL COLUMNS")')
	  OPEN(678,FILE='KINETIC.DAT')
	  WRITE(678,'("TIME   KINETIC DIFFERENCES ACROSS DIFFERENT I-CELL COLUMNS")')
	ENDIF
	FIRSTTIME=.TRUE.
  ENDIF
  TIMESTEP=tbegin+float(N)*dt/86400.0
!  write(765,*)TIMESTEP,SUM(WQV(3,1:KC,3)*DZC(1:KC))
  ITEMPMSK=1
  DO ILL=2,LA
    IF(MVEGL(ILL)>90)THEN
      ESTORAGE(ITEMPMSK,1)=SUM(ESUP(:,ILL))
      ESTORAGE(ITEMPMSK,2)=SUM(EMHK(:,ILL))
      ITEMPMSK=ITEMPMSK+1
    ENDIF
  ENDDO  
  IF(MAXVAL(MVEGL(2:LA))>90)WRITE(222,'(F7.3,100(F7.4,1X))')TIMESTEP,(ESTORAGE(ILL,1),ESTORAGE(ILL,2),ILL=1,TCOUNT)
  nstep=nstep+1
  IF(nstep>9999)PRINT*,'Tecplot timestamp is greater than 9999, increase field width or reduce writing frequency'								
  WRITE(timeline(31:34),'(I4.4)')nstep
  WRITE(111,'(A66,I4.4)')timeline,nstep
! WRITE(110,*)'ZONE T="',tbegin+float(nstep-1)*dt*float(ishprt)/86400.0,'" I= ' ,IC-4,' J= ' ,JC-4,' K = ',KC,' F=POINT'
  IF(IDNOTRVA/=0)THEN
    WRITE(111,*)'ZONE T="',TIMESTEP,'" I= ' ,3,' J= ' ,3,' F=POINT' !HARD WIRDED FOR NOW********
  ELSE
    WRITE(111,*)'ZONE T="',TIMESTEP,'" I= ' ,IC-4,' J= ' ,JC-4,' F=POINT'
  ENDIF
  IF(IDNOTRVA/=0)THEN !Macroalgae  
    DO J=3,JC-2
      DO I=3,IC-2
        L=LIJ(I,J)
        IF(MVEGL(L)>0.AND.MVEGL(L)<90) THEN
!VB       TWATER=SUM(TEM(LIJ(I,J),1:KC)*DZC(1:KC))
!	      TALT=MAXVAL(TWQ(LIJ(I,J))
          UTMPS=0.0;VTMPS=0.0;WTEMP=0.0;WQV10=0.0;WQV14=0.0;WQV15=0.0;WQV23=0.0
          IlimMac=0.0;TlimMac=0.0;NlimMac=0.0;PlimMac=0.0;MacGro=0.0;LOCALVOL=0.0
          DO K=1,KC
            IF(HP(L)*Z(K)>=ZMINMAC(L).AND.HP(L)*Z(K)<=ZMAXMAC(L))THEN !Macroalgae in this layer
              LOCALVOL=LOCALVOL+DZC(K)
	          UTMPS=UTMPS+(U(L,K)*CUE(L)+V(L,K)*CVE(L))*DZC(K)
	          VTMPS=VTMPS+(U(L,K)*CUN(L)+V(L,K)*CVN(L))*DZC(K)
  	          WTEMP=WTEMP+TEM(L,K)*DZC(K) !Temperature
              IlimMac=IlimMac+MACLIM(L,K,2)*DZC(K) !light limitation
              TlimMac=TlimMac+MACLIM(L,K,3)*DZC(K) !temperature limitation
              NlimMac=NlimMac+MACLIM(L,K,4)*DZC(K) !nitrate limitation
              PlimMac=PlimMac+MACLIM(L,K,5)*DZC(K) !phosphate limitation
              MacGro=MacGro+MACLIM(L,K,1)*DZC(K)   !Growth rate
              WQV10=WQV10+WQV(L,K,10)*DZC(K) !total phosphate
              WQV14=WQV14+WQV(L,K,14)*DZC(K) !ammonia nitrogen
              WQV15=WQV15+WQV(L,K,15)*DZC(K) !nitrate nitrogen
              WQV23=WQV23+WQV(L,K,IDNOTRVA)*DZC(K) !macroalgae
            ENDIF
          ENDDO !Calculate volume-weighted averages
          IF(LOCALVOL==0.0)LOCALVOL=1.0
          WRITE(111,'(4(1X,F10.3), 7(1X,F10.4))')DLON(L),DLAT(L),UTMPS/LOCALVOL,VTMPS/LOCALVOL,WQV23/LOCALVOL, &
           WTEMP/LOCALVOL,IlimMac/LOCALVOL,TlimMac/LOCALVOL,NlimMac/LOCALVOL,PlimMac/LOCALVOL,MacGro/LOCALVOL
	    ENDIF
      ENDDO
    ENDDO
    !WTEMP=0.0
    !WQV3=0;WQV10=0;WQV14=0;WQV15=0;WQV10=0;WQV22=0
    !DO L=2, LA
    !  VOLTEMP = DXYP(L)*HP(L)
    !  WVOL = WVOL + VOLTEMP
    !  WTEMP=WTEMP+VOLTEMP*SUM(DZC(1:KC)*TEM(L,1:KC))
    !  WQV3=WQV3+VOLTEMP*SUM(DZC(1:KC)*WQV(L,1:KC,3))
    !  WQV10=WQV10+VOLTEMP*SUM(DZC(1:KC)*WQV(L,1:KC,10))
    !  WQV14=WQV14+VOLTEMP*SUM(DZC(1:KC)*WQV(L,1:KC,14))
    !  WQV15=WQV15+VOLTEMP*SUM(DZC(1:KC)*WQV(L,1:KC,15))
    !  WQV19=WQV19+VOLTEMP*SUM(DZC(1:KC)*WQV(L,1:KC,19))
    !  WQV22=WQV22+VOLTEMP*SUM(DZC(1:KC)*WQV(L,1:KC,22))
    !ENDDO
    !WRITE(112,'(10(f9.4,1x))')timestep,WTEMP/WVOL,WQV3/WVOL,WQV19/WVOL,WQV22/WVOL,WQV10/WVOL,WQV14/WVOL,WQV15/WVOL              
  ELSEIF(ISTRAN(8)==1)THEN
!VB HEAT CONTENT VARIABLE
    RHOw=1000	   !KG/M3
    HTCAP=4.187	   !kJ/KG-K
    HTCONT=0.0
    WQVTEMP=0.0
! 2 Dimensional Output !VB REWRITTEN TO OUTPUT TIME SERIES PLOTS
    DO J=3,JC-2
      DO I=3,IC-2
        IF(LIJ(I,J)>0) THEN
!VB       TWATER=SUM(TEM(LIJ(I,J),1:KC)*DZC(1:KC))
!	      TALT=MAXVAL(TWQ(LIJ(I,J))
          L=LIJ(I,J)
	      UTMPS=SUM((U(L,1:KC)*CUE(L)+V(L,1:KC)*CVE(L))*DZC(1:KC))
	      VTMPS=SUM((U(L,1:KC)*CUN(L)+V(L,1:KC)*CVN(L))*DZC(1:KC))
	      MAG=SQRT((UTMPS)**2+(VTMPS)**2)
	      WTEMP=SUM((TEM(L,1:KC)+273.15)*DZC(1:KC)*DXYP(L)*HP(L))
	      WTMP=WTMP+WTEMP
	      HTEMP=RHOw*HTCAP*WTEMP
	      HTCONT=HTCONT+HTEMP						!HEAT CONTENT IN KILOJOULES										
	      WQV2=SUM(WQV(L,1:KC,2)*DZC(1:KC)) !*DXYP(LIJ(I,J))*HP(L))
	      WQV3=SUM(WQV(L,1:KC,3)*DZC(1:KC)) !*DXYP(LIJ(I,J))*HP(L))
	      WQV6=SUM(WQV(L,1:KC,6)*DZC(1:KC))  !*DXYP(LIJ(I,J))*HP(L))
	      WQV10=SUM(WQV(L,1:KC,10)*DZC(1:KC))  !*DXYP(LIJ(I,J))*HP(L))
	      WQV14=SUM(WQV(L,1:KC,14)*DZC(1:KC))  !*DXYP(LIJ(I,J))*HP(L))
	      WQV15=SUM(WQV(L,1:KC,15)*DZC(1:KC))  !*DXYP(LIJ(I,J))*HP(L))
	      WQV16=SUM(WQV(L,1:KC,16)*DZC(1:KC))  !*DXYP(LIJ(I,J))*HP(L))
	      WQV17=SUM(WQV(L,1:KC,17)*DZC(1:KC))  !*DXYP(LIJ(I,J))*HP(L))
	      WQV19=SUM(WQV(L,1:KC,19)*DZC(1:KC)) !*DXYP(LIJ(I,J))*HP(L))
	      WQV22=SUM(WQV(L,1:KC,22)*DZC(1:KC)) !*DXYP(LIJ(I,J))*HP(L))
	      WRITE(111,'(5(1X,F11.2), 7(1X,F11.4))')DLON(L),DLAT(L),UTMPS,VTMPS,MAG,WQV3,WQV10,WQV14,WQV15,WQV19,WQV22
	    ENDIF
      ENDDO
    ENDDO
    WTEMP=0.0
    WQV3=0;WQV10=0;WQV14=0;WQV15=0;WQV10=0;WQV22=0
    DO L=2, LA
      VOLTEMP = DXYP(L)*HP(L)
      WVOL = WVOL + VOLTEMP
      WTEMP=WTEMP+VOLTEMP*SUM(DZC(1:KC)*TEM(L,1:KC))
      WQV3=WQV3+VOLTEMP*SUM(DZC(1:KC)*WQV(L,1:KC,3))
      WQV10=WQV10+VOLTEMP*SUM(DZC(1:KC)*WQV(L,1:KC,10))
      WQV14=WQV14+VOLTEMP*SUM(DZC(1:KC)*WQV(L,1:KC,14))
      WQV15=WQV15+VOLTEMP*SUM(DZC(1:KC)*WQV(L,1:KC,15))
      WQV19=WQV19+VOLTEMP*SUM(DZC(1:KC)*WQV(L,1:KC,19))
      WQV22=WQV22+VOLTEMP*SUM(DZC(1:KC)*WQV(L,1:KC,22))
    ENDDO
    WRITE(112,'(10(f9.4,1x))')timestep,WTEMP/WVOL,WQV3/WVOL,WQV19/WVOL,WQV22/WVOL,WQV10/WVOL,WQV14/WVOL,WQV15/WVOL              
  ELSEIF(IWRSP(1)==98)THEN			
! OUTPUT FOR TECPLOT, SEDIMENT DATA
    MB(1) = 0.0 !Mass in bedload (kg)
    MB(2) = 0.0 !Mass in suspension (kg)
    !MB(3)     !Mass exiting in suspension (stored)
    !MB(4)     !Mass exiting as bedload (stored)
    MB(5) = 0.0 !Mass eroded from bed (kg)
    FORALL(L=2:LA) !added to convert THCK from g/cm^2 to cm
      TSEDT(L)=SUM(TSED(1:KB,L)/BULKDENS(1:KB,L))
    ENDFORALL
    FORALL(L = 2:LA) THCK(L) = TSEDT(L) - TSET0T(L)
    DO J = 3,JC-2
      DO I = 3,IC-2
        L=LIJ(I,J)
        CBLTOT(L) = 10.0*SUM(CBL(1,L,1:NSCM)*DZBL(L,1:NSCM))*DXYP(L) !g/cm^3*cm*m^2*(0.001*100*100)
        CTEMP1(1:KC) = 0.001*SUM(SED(L,1:KC,1:NSCM))
        MB(1) = MB(1) + CBLTOT(L)
        DO K = 1,KC
          MB(2) = MB(2) + CTEMP1(K)*DZC(K)*DXYP(L)*HP(L) !g/m^3*m^2*m*(0.001)
          UVEL(L,K) = U(L,K)*CUE(L) + V(L,K)*CVE(L)
          VVEL(L,K) = U(L,K)*CUN(L) + V(L,K)*CVN(L)
          IF(I == IC-3)THEN
            !MB(3) = MB(3) - DT*VVEL(LIJ(I,J),K)*DYP(LIJ(I,J))*DZC(K)*HP(LIJ(I,J))*SUM(SED(LIJ(I,J),K,1:NSCM))*0.001 !Dt*m/s*m*m*g/m^3*(0.001)
            MB(3) = MB(3) - 0.25*DT*VVEL(L,K)*DYP(L)*DZC(K)*(HP(L) + HP(LIJ(I+1,J)))*(SUM(SED(L,K,1:NSCM)) &
            + SUM(SED(LIJ(I+1,J),K,1:NSCM)))*0.001 !Dt*m/s*m*m*g/m^3*(0.001)
          ENDIF
        ENDDO
        IF(I == IC-3)THEN
          MB(4) = MB(4) - 0.05*DT*DYP(L)*SUM((UBL(L,1:NSCM)*CUN(L) + VBL(L,1:NSCM)*CVN(L))*(CBL(1,L,1:NSCM)*  &
                 DZBL(L,1:NSCM) + CBL(1,LIJ(I+1,J),1:NSCM)*DZBL(LIJ(I+1,J),1:NSCM))) !Dt*m*cm/s*g/cm^3*cm*(0.001*100)
          !MB(4) = MB(4) - DT*DYP(LIJ(I,J))*(UBL(LIJ(I,J),1)*CUN(LIJ(I,J)) + VBL(LIJ(I,J),1)*CVN(LIJ(I,J)))*0.5*(CBL(1,LIJ(I,J),1) + CBL(1,LIJ(I+1,J),1))*DZBL(LIJ(I,J),1))*0.1 !Dt*m*cm/s*g/cm^3*cm*(0.001*100)
        ENDIF
        MB(5) = MB(5) - 10.0*THCK(L)*DXYP(L) !g/cm^2*m^2*(0.001*100*100)
        AVGSED(L) = SUM(CTEMP1(1:KC)*DZC(1:KC))*DXYP(L)*HP(L)
        !WRITE(111,'(I4,1X,I4,1X,10(E13.4,1X))')I, J, DLON(LIJ(I,J)), DLAT(LIJ(I,J)), TAU(LIJ(I,J)), D50AVG(LIJ(I,J)), CBLTOT(LIJ(I,J)), AVGSED(LIJ(I,J)), SUM((U(LIJ(I,J),1:KC)*CUE(LIJ(I,J)) + V(LIJ(I,J),1:KC)*CVE(LIJ(I,J)))*DZC(1:KC)), SUM((U(LIJ(I,J),1:KC)*CUN(LIJ(I,J)) + V(LIJ(I,J),1:KC)*CVN(LIJ(I,J)))*DZC(1:KC)), SUM(TSED(1:KB,LIJ(I,J)))/1.4625, THCK(LIJ(I,J))/1.4625
 	    UTMPS=SUM((U(L,1:KC)*CUE(L)+V(L,1:KC)*CVE(L))*DZC(1:KC))
	    VTMPS=SUM((U(L,1:KC)*CUN(L)+V(L,1:KC)*CVN(L))*DZC(1:KC))
	    MAG=SQRT((UTMPS)**2+(VTMPS)**2)
        WRITE(111,'(I4,1X,I4,1X,10(E13.4,1X))')I, J, DLON(L), DLAT(L), TAU(L), D50AVG(L), CBLTOT(L), AVGSED(L), &
              SUM((U(L,1:KC)*CUE(L) + V(L,1:KC)*CVE(L))*DZC(1:KC)), SUM((U(L,1:KC)*CUN(L) + V(L,1:KC)*CVN(L))*  &
          DZC(1:KC)), THCK(L), MAG
      ENDDO
    ENDDO
    !PRINT*,TBEGIN + FLOAT(N-1)*DT,MB(1),MB(2),MB(3),MB(4),MB(5),SUM(TAU(2:LA))/FLOAT(LA-1),MAXVAL(TAU(2:LA))
    !WRITE(112,'(8(E13.4,1X))')TBEGIN + FLOAT(N-1)*DT,MB(1),MB(2),MB(3),MB(4),MB(5),SUM(TAU(2:LA))/FLOAT(LA-1),MAXVAL(TAU(2:LA))
    WRITE(112,'(8(E13.4,1X))')TIMESTEP,MB(1),MB(2),MB(3),MB(4),MB(5),(MB(5)-(MB(1) + MB(2))-ELAST)/((TBEGIN + &
           FLOAT(N-1)*DT)-TLAST),SUM(D50AVG(:))/(FLOAT(LA-1))
    ELAST = MB(5)-(MB(1) + MB(2)) !Erosion is saved (as mass eroded, minus the mass in the water column)
    TLAST = TBEGIN + FLOAT(N-1)*DT
    !print *,SNGL(CBL(1,LIJ(13,4),1:7))
    !print *,SNGL(SED(LIJ(13,4),KC,1:7))
    !print *, maxval(tau(2:LA)), minval(tau(2:LA))
  ELSE
    DO J=3,JC-2
      DO I=3,IC-2
        IF(LIJ(I,J)>0) THEN
          L=LIJ(I,J)
          UTMPS=SUM((U(L,1:KC)*CUE(L)+V(L,1:KC)*CVE(L))*DZC(1:KC))
	      VTMPS=SUM((U(L,1:KC)*CUN(L)+V(L,1:KC)*CVN(L))*DZC(1:KC))
	      MAG=SQRT((UTMPS)**2+(VTMPS)**2)
	      WRITE(111,'(5(1X,F11.2), 7(1X,F11.4))')DLON(L),DLAT(L),UTMPS,VTMPS,MAG,TAUB(L),HP(L)
        ENDIF
      ENDDO
    ENDDO
  ENDIF	
  IF(OUTPUTFLAG==1)THEN !MHK look at power up- and down-stream of the MHK device
    ALLOCATE(MDOTU(IC, JC, KC))
    ALLOCATE(MDOTD(IC, JC, KC))
    PUPSTREAM=0.0;PDNSTREAM=0.0;PUPPOT=0.0;PDNPOT=0.0;PUPKIN=0.0
    PDNKIN=0.0;PUP=0.0;PDN=0.0;KUP=0.0;KDN=0.0;PPUP=0.0;PPDN=0.0;
    MDOTU=0.0;MDOTD=0.0
    DO I=1,3
      DO J=3,JC-2
        LL1=LIJ(42-I,J) !looking where whatever integer is in this expression and the next
        LL2=LIJ(I+43,J)
        DO K=1,KC  
          MDOTU(I,J,K)=1024.0*U(LL1,K)*DYU(LL1)*DZC(K)*HU(LL1)
          MDOTD(I,J,K)=1024.0*U(LL2,K)*DYU(LL2)*DZC(K)*HU(LL2)
          PUPKIN(I,J)=PUPKIN(I,J)+0.5*MDOTU(I,J,K)*U(LL1,K)**2
          PDNKIN(I,J)=PDNKIN(I,J)+0.5*MDOTD(I,J,K)*U(LL2,K)**2
        ENDDO
        PUPPOT(I,J)=SUM(MDOTU(I,J,1:KC))*G*HU(LL1)
        PDNPOT(I,J)=SUM(MDOTD(I,J,1:KC))*G*HU(LL2)
        DELTA(I,J)=SUM(MDOTU(I,J,1:KC))-SUM(MDOTD(I,J,1:KC))
!        EUPSTREAM(I,J)=0.5*DXP(LL1)*HP(LL1)*1024.*SUM((U(LL1,1:KC)+U(LL1+1,1:KC))*DZC(1:KC)*(0.5*(0.5*(U(LL1,1:KC)+U(LL1+1,1:KC)))**2+9.8106*HP(LL1)))
!        EDNSTREAM(I,J)=0.5*DXP(LL2)*HP(LL2)*1024.*SUM((U(LL2,1:KC)+U(LL2+1,1:KC))*DZC(1:KC)*(0.5*(0.5*(U(LL2,1:KC)+U(LL2+1,1:KC)))**2+9.8106*HP(LL2)))
        PUPSTREAM(I,J)=PUPPOT(I,J)+PUPKIN(I,J)
        PDNSTREAM(I,J)=PDNPOT(I,J)+PDNKIN(I,J)
      ENDDO
      MCHANGE=SUM(MDOTU(I,3:JC-2,1:KC))-SUM(MDOTD(I,3:JC-2,1:KC))
      PUP(I)=SUM(PUPPOT(I,3:JC-2))
      PDN(I)=SUM(PDNPOT(I,3:JC-2))
      KUP(I)=SUM(PUPKIN(I,3:JC-2))
      KDN(I)=SUM(PDNKIN(I,3:JC-2))
      PPUP(I)=SUM(PUPSTREAM(I,3:JC-2))
      PPDN(I)=SUM(PDNSTREAM(I,3:JC-2))
      continue
    ENDDO
    WRITE(765,'(E10.3,8(1X,F10.1))')TIMESTEP,(SUM(PUPSTREAM(I,3:JC-2))-SUM(PDNSTREAM(I,3:JC-2)),I=1,3)
    WRITE(567,'(E10.3,16(1X,F10.0))')TIMESTEP,(SUM(PUPPOT(I,3:JC-2)),I=1,3),(SUM(PDNPOT(I,3:JC-2)),I=1,3)
    WRITE(678,'(E10.3,16(1X,F10.1))')TIMESTEP,(SUM(PUPKIN(I,3:JC-2)),I=1,3),(SUM(PDNKIN(I,3:JC-2)),I=1,3)
  ENDIF
 !OUTPUTFLAG=2 !Tidal reference model average and z-profile velocities
  IF(OUTPUTFLAG==2)THEN
    I=60
    VELPDF=0.0
    DO J=3,JC-2
      L=LIJ(I,J)
      UTMPS=SUM((U(L,1:KC)*CUE(L)+V(L,1:KC)*CVE(L))*DZC(1:KC))
      VTMPS=SUM((U(L,1:KC)*CUN(L)+V(L,1:KC)*CVN(L))*DZC(1:KC))
      MAG=SQRT((UTMPS)**2+(VTMPS)**2)
      VELPDF=VELPDF+MAG
    ENDDO
    VELPDF=VELPDF/FLOAT(JC-4)
    WRITE(468,*)TIMESTEP,VELPDF
    WRITE(579,'(E10.3,10(1X,F6.3))')TIMESTEP,((U(L,K)*CUE(L)+V(L,K)*CVE(L)),K=1,KC)
  ENDIF
 IF(OUTPUTFLAG==3)THEN !average and surface velocities for tidal reference model
   J=20
   DO I=3,IC-2
     L=LIJ(I,J)
     LE=LIJ(I+1,J)
     UTMPS=SUM(0.5*((U(L,1:KC)*CUE(L)+V(L,1:KC)*CVE(L))*DZC(1:KC))+0.5*((U(LE,1:KC)*CUE(LE)+V(LE,1:KC)*CVE(LE))*DZC(1:KC)))
     VTMPS=SUM(0.5*((U(L,1:KC)*CUN(L)+V(L,1:KC)*CVN(L))*DZC(1:KC))+0.5*((U(LE,1:KC)*CUN(LE)+V(LE,1:KC)*CVN(LE))*DZC(1:KC)))
     MAGREF1(I-2)=VTMPS
     UTMP=     0.5*(U(L,KC) *CUE(L) +V(L,KC) *CVE(L))
     UTMP=UTMP+0.5*(U(LE,KC)*CUE(LE)+V(LE,KC)*CVE(LE))
     UTMPS=UTMP
     VTMP=     0.5*(U(L,KC) *CUN(L)+ V(L,KC)* CVN(L))
     VTMP=VTMP+0.5*(U(LE,KC)*CUN(LE)+V(LE,KC)*CVN(LE))
     VTMPS=VTMP
     MAGREF2(I-2)=VTMPS
   ENDDO
   WRITE(864,'(84(F6.3,1X))')(MAGREF1(I-2),I=3,IC-2)
   WRITE(864,'(84(F6.3,1X))')(MAGREF2(I-2),I=3,IC-2)
   WRITE(864,'(84(F6.3,1X))')(HP(I-2),I=3,IC-2)
 ENDIF
 IF(OUTPUTFLAG==4)THEN !this interrogates the W-2-E straight flow channel for wake calibration, IFREMER flume
   UPVEL=0.0;DNVEL=0.0;ATVEL=0.0;COUNTER=0;VEL3=0.;VEL4=0.;VEL5=0.;VEL6=0.;VEL7=0.;VEL8=0.;VEL9=0.;VEL10=0.;VEL11=0.;VEL14=0.
   UPVEL=U(LIJ(5,15),8) !cells upstream
   IF(DENMHK(1)==0.2)THEN
     VEL3=U(LIJ(55,15),8) ! 5 cells per turbine
     VEL4=U(LIJ(60,15),8)
     VEL5=U(LIJ(65,15),8)
     VEL6=U(LIJ(70,15),8)
     VEL7=U(LIJ(75,15),8)
     VEL8=U(LIJ(80,15),8)
     VEL9=U(LIJ(85,15),8)
     VEL10=U(LIJ(90,15),8)
     VEL11=U(LIJ(95,15),8)
     VEL14=U(LIJ(110,15),8)
   ELSE
     VEL3=U(LIJ(34,10),8) ! 3 cells per turbine
     VEL4=U(LIJ(37,10),8)
     VEL5=U(LIJ(40,10),8)
     VEL6=U(LIJ(43,10),8)
     VEL7=U(LIJ(46,10),8)
     VEL8=U(LIJ(49,10),8)
     VEL9=U(LIJ(52,10),8)
     VEL10=U(LIJ(55,10),8)
     VEL11=U(LIJ(58,10),8)
     VEL14=U(LIJ(67,10),8)
   ENDIF
   WRITE(444,'(e10.2,1x,10(f7.4,1x))')TIMESTEP,1.0-VEL3/UPVEL,1.0-VEL4/UPVEL,1.0-VEL5/UPVEL,1.0-VEL6/UPVEL, &
     1.0-VEL7/UPVEL,1.0-VEL8/UPVEL,1.0-VEL9/UPVEL,1.0-VEL10/UPVEL,1.0-VEL11/UPVEL,1.0-VEL14/UPVEL !calculate velocity ratio, we are looking for 90% recovery at 20D downstream
 ELSEIF(OUTPUTFLAG==5)THEN !this interrogates the W-2-E straight flow channel for wake calibration, Chilworth flume
   UPVEL=0.0;DNVEL=0.0;ATVEL=0.0;COUNTER=0;VEL3=0.;VEL4=0.
   VEL5=0.;VEL6=0.;VEL7=0.;VEL9=0.;VEL11=0.;VEL13=0.;VEL15=0.;VEL17=0.;VEL20=0.
   UPVEL=U(LIJ(55,23),6) 
   VEL3=U(LIJ(71,23),6)
   VEL4=U(LIJ(74,23),6)
   VEL5=U(LIJ(77,23),6)
   VEL6=U(LIJ(80,23),6)
   VEL7=U(LIJ(83,23),6)
   VEL9=U(LIJ(89,23),6)
   VEL11=U(LIJ(95,23),6)
   VEL13=U(LIJ(101,23),6)
   VEL15=U(LIJ(107,23),6)
   VEL17=U(LIJ(113,23),6)
   VEL20=U(LIJ(122,23),6)
   WRITE(444,'(e10.2,1x,11(f7.4,1x))')TIMESTEP,1.0-VEL3/UPVEL,1.0-VEL4/UPVEL,1.0-VEL5/UPVEL,1.0-VEL6/UPVEL, &
     1.0-VEL7/UPVEL,1.0-VEL9/UPVEL,1.0-VEL11/UPVEL,1.0-VEL13/UPVEL,1.0-VEL15/UPVEL,1.0-VEL17/UPVEL,1.0-VEL20/UPVEL !calculate velocity ratio, we are looking for 90% recovery at 20D downstream
 ELSEIF(OUTPUTFLAG==6)THEN !this interrogates the W-2-E straight flow channel for wake calibration, SAFL flume
   UPVEL=0.0;DNVEL=0.0;ATVEL=0.0;COUNTER=0;VEL1=0.;VEL2=0.;
VEL3=0.;VEL4=0.;VEL5=0.;VEL6=0.;VEL7=0.;VEL8=0.;VEL9=0.;VEL10=0.;
VEL11=0.;VEL12=0.;VEL13=0.;VEL14=0.;VEL15=0.;VEL16=0.;VEL17=0.;VEL18=0.;VEL19=0.
   UPVEL=U(LIJ(5,17),4) !cells upstream
   VEL1=U(LIJ(58,17),4)
   VEL2=U(LIJ(63,17),4)
   VEL3=U(LIJ(68,17),4)
   VEL4=U(LIJ(73,17),4)
   VEL5=U(LIJ(78,17),4)
   VEL6=U(LIJ(83,17),4)
   VEL7=U(LIJ(88,17),4)
   VEL8=U(LIJ(93,17),4)
   VEL9=U(LIJ(98,17),4)
   VEL10=U(LIJ(103,17),4)
   VEL11=U(LIJ(108,17),4)
   VEL12=U(LIJ(113,17),4)
   VEL13=U(LIJ(118,17),4)
   VEL14=U(LIJ(123,17),4)
   VEL15=U(LIJ(128,17),4)
   VEL16=U(LIJ(133,17),4)
   VEL17=U(LIJ(138,17),4)
   VEL18=U(LIJ(143,17),4)
   VEL19=U(LIJ(148,17),4)
   WRITE(444,'(e10.2,1x,19(f7.4,1x))')TIMESTEP,1.0-VEL1/UPVEL,1.0-VEL1/UPVEL,1.0-VEL3/UPVEL,1.0-VEL4/UPVEL, &
       1.0-VEL5/UPVEL,1.0-VEL6/UPVEL,1.0-VEL7/UPVEL,1.0-VEL8/UPVEL,1.0-VEL9/UPVEL,1.0-VEL10/UPVEL,1.0-VEL11/UPVEL, &
       1.0-VEL12/UPVEL,1.0-VEL13/UPVEL,1.0-VEL14/UPVEL,1.0-VEL15/UPVEL,1.0-VEL16/UPVEL,1.0-VEL17/UPVEL,1.0-VEL18/UPVEL,& 
       1.0-VEL19/UPVEL !calculate velocity ratio, we are looking for 90% recovery at 20D downstream
 ELSEIF(OUTPUTFLAG==10)THEN !misc tecplot file, currently cross-section at 3D downstream of 2 discs in Chilworth
   UPVEL=0.0;DNVEL=0.0;ATVEL=0.0;COUNTER=0;VEL1=0.;VEL2=0.;
   VEL3=0.;VEL4=0.;VEL5=0.;VEL6=0.;VEL7=0.;VEL8=0.;VEL9=0.;
   VEL10=0.;VEL11=0.;VEL12=0.;VEL13=0.;VEL14=0.;VEL15=0.
   UPVEL=U(LIJ(5,24),5) !cells upstream
   VEL1=U(LIJ(77,36),5)
   VEL2=U(LIJ(77,33),5)
   VEL3=U(LIJ(77,30),5) ! +2D
   VEL4=U(LIJ(77,29),5)
   VEL5=U(LIJ(77,28),5)
   VEL6=U(LIJ(77,27),5)
   VEL7=U(LIJ(77,26),5)
   VEL8=U(LIJ(77,24),5) ! center cell
   VEL9=U(LIJ(77,22),5)
   VEL10=U(LIJ(77,21),5)
   VEL11=U(LIJ(77,20),5)
   VEL12=U(LIJ(77,19),5)
   VEL13=U(LIJ(77,18),5) ! -2D
   VEL14=U(LIJ(77,15),5)
   VEL15=U(LIJ(77,12),5)
   WRITE(444,'(e10.2,1x,20(f7.4,1x))')5.0,VEL1,VEL2,VEL3,VEL4,VEL5,VEL6,VEL7,VEL8,VEL9,VEL10,VEL11,VEL12,VEL13,VEL14,VEL15 !calculate velocity ratio, we are looking for 90% recovery at 20D downstream
   VEL1=U(LIJ(83,36),5)
   VEL2=U(LIJ(83,33),5)
   VEL3=U(LIJ(83,30),5) ! +2D
   VEL4=U(LIJ(83,29),5)
   VEL5=U(LIJ(83,28),5)
   VEL6=U(LIJ(83,27),5)
   VEL7=U(LIJ(83,26),5)
   VEL8=U(LIJ(83,24),5) ! center cell
   VEL9=U(LIJ(83,22),5)
   VEL10=U(LIJ(83,21),5)
   VEL11=U(LIJ(83,20),5)
   VEL12=U(LIJ(83,19),5)
   VEL13=U(LIJ(83,18),5) ! -2D
   VEL14=U(LIJ(83,15),5)
   VEL15=U(LIJ(83,12),5)
   WRITE(444,'(e10.2,1x,20(f7.4,1x))')7.0,VEL1,VEL2,VEL3,VEL4,VEL5,VEL6,VEL7,VEL8,VEL9,VEL10,VEL11,VEL12,VEL13,VEL14,VEL15
   VEL1=U(LIJ(89,36),5)
   VEL2=U(LIJ(89,33),5)
   VEL3=U(LIJ(89,30),5) ! +2D
   VEL4=U(LIJ(89,29),5)
   VEL5=U(LIJ(89,28),5)
   VEL6=U(LIJ(89,27),5)
   VEL7=U(LIJ(89,26),5)
   VEL8=U(LIJ(89,24),5) ! center cell
   VEL9=U(LIJ(89,22),5)
   VEL10=U(LIJ(89,21),5)
   VEL11=U(LIJ(89,20),5)
   VEL12=U(LIJ(89,19),5)
   VEL13=U(LIJ(89,18),5) ! -2D
   VEL14=U(LIJ(89,15),5)
   VEL15=U(LIJ(89,12),5)
   WRITE(444,'(e10.2,1x,20(f7.4,1x))')9.0,VEL1,VEL2,VEL3,VEL4,VEL5,VEL6,VEL7,VEL8,VEL9,VEL10,VEL11,VEL12,VEL13,VEL14,VEL15
   VEL1=U(LIJ(137,36),5)
   VEL2=U(LIJ(137,33),5)
   VEL3=U(LIJ(137,30),5) ! +2D
   VEL4=U(LIJ(137,29),5)
   VEL5=U(LIJ(137,28),5)
   VEL6=U(LIJ(137,27),5)
   VEL7=U(LIJ(137,26),5)
   VEL8=U(LIJ(137,24),5) ! center cell
   VEL9=U(LIJ(137,22),5)
   VEL10=U(LIJ(137,21),5)
   VEL11=U(LIJ(137,20),5)
   VEL12=U(LIJ(137,19),5)
   VEL13=U(LIJ(137,18),5) ! -2D
   VEL14=U(LIJ(137,15),5)
   VEL15=U(LIJ(137,12),5)
   WRITE(444,'(e10.2,1x,20(f7.4,1x))')25.0,VEL1,VEL2,VEL3,VEL4,VEL5,VEL6,VEL7,VEL8,VEL9,VEL10,VEL11,VEL12,VEL13,VEL14,VEL15
 ENDIF
 RETURN
END SUBROUTINE TECPLOT
