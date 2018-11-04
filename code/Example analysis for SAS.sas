/* plot original data to find out if they have any relationships */
proc template;
define statgraph sgdesign;
dynamic _HEIGHT _GIRTH _VOLUME;
begingraph;
   layout lattice;
      scatterplotmatrix _HEIGHT _GIRTH _VOLUME / name='scatterplotmatrix' markerattrs=(color=CX0000FF );
   endlayout;
endgraph;
end;
run;

proc sgrender data=Trees template=sgdesign;
dynamic _HEIGHT="HEIGHT" _GIRTH="GIRTH" _VOLUME="VOLUME";
run;


/* run our bootstrap */
%regBoot(NumberOfLoops=1000, DataSet=Trees, XVariable=Girth, YVariable=Height);
