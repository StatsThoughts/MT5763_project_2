PROC IMPORT OUT= WORK.Trees 
            DATAFILE= "D:\Bryant\Documents\Uni\Work\MT5763\Project 2\MT5
763_project_2\data\trees.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
