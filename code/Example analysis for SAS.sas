/* plot original data to find out if they have obviously relationship */
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

proc sgrender data=TREE.SQ template=sgdesign;
dynamic _HEIGHT="HEIGHT" _GIRTH="GIRTH" _VOLUME="VOLUME";
run;


/* run our bootstrap */
%regBoot(NumberOfLoops=1000, DataSet=TREE.Trees, XVariable=Girth, YVariable=Height);
%regBoot(NumberOfLoops=1000, DataSet=TREE.Trees, XVariable=Volume, YVariable=Height);
