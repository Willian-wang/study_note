#答案是自己写的，可能存在问题
也可以参考：
https://blog.csdn.net/flycat296/article/details/63681089
https://zhuanlan.zhihu.com/p/32137597

# 1. 查询" 01 "课程比" 02 "课程成绩高的学生的信息及课程分数
SELECT student.*,score1,score2
FROM student INNER JOIN
  (SELECT S1.score As score1, S2.score AS score2 , S1.SId AS ID
  FROM sc AS S1  JOIN sc AS S2
  ON S1.SId=S2.Sid
  WHERE S1.CId=1 AND S2.CId=2 AND S1.score>S2.score)
AS T  ON  T.ID=student.SId;
# 1.1 查询同时存在" 01 "课程和" 02 "课程的情况
SELECT *
FROM student JOIN
  ((SELECT  SID,score FROM sc WHERE  sc.CId=1) AS t1 JOIN
    (SELECT SID,score FROM  sc WHERE sc.CId=2) AS t2 ON t1.SId=t2.SId)
ON t1.SId=student.SId;
# 1.2 查询存在" 01 "课程但可能不存在" 02 "课程的情况(不存在时显示为 null )
SELECT *
FROM student JOIN
  (SELECT SID ,score FROM  sc WHERE sc.CId=1) AS t1 LEFT JOIN
  (SELECT SID, score FROM  sc WHERE  sc.CId=2) AS t2 ON t1.SId=t2.SId
ON student.SId=t1.SId;
# 1.3 查询不存在" 01 "课程但存在" 02 "课程的情况
SELECT *
FROM sc
WHERE sc.SId NOT IN (SELECT SId FROM sc WHERE sc.CId=1)
AND sc.CId=2;
# 2. 查询平均成绩大于等于 60 分的同学的学生编号和学生姓名和平均成绩
SELECT AVG(score),sc.SId ,student.*  FROM  sc,student WHERE student.SId=sc.SId GROUP BY (sc.SId) HAVING AVG(score)>60;
# 3. 查询在 SC 表存在成绩的学生信息
SELECT * FROM student,(SELECT SId FROM sc GROUP BY SId) AS id WHERE id.SId=student.SId;
# 4. 查询所有同学的学生编号、学生姓名、选课总数、所有课程的总成绩(没成绩的显示为 null )
SELECT student.SId,student.Sname,t4.count,t1.score,t2.score,t3.score
FROM student LEFT JOIN
     (SELECT SId,score FROM sc WHERE  CId=1) AS t1 ON t1.SId=student.SId LEFT OUTER JOIN
     (SELECT  SId,score FROM sc WHERE  CId=2) AS t2 ON t2.SId=student.SId LEFT OUTER JOIN
     (SELECT SId,score FROM sc WHERE  CId=3) AS t3 ON t3.SId=student.SId LEFT OUTER JOIN
     (SELECT COUNT(score) AS count,SId FROM sc GROUP BY SId ) AS t4 ON t4.SId=student.SId;
# 4.1 查有成绩的学生信息
SELECT * FROM student,(SELECT SId FROM sc GROUP BY SId) AS id WHERE id.SId=student.SId;
# 5. 查询「李」姓老师的数量
SELECT * FROM teacher WHERE Tname LIKE "李%";
# 6. 查询学过「张三」老师授课的同学的信息
SELECT *
FROM student
WHERE SId IN (SELECT SId FROM sc WHERE CId IN
                                       (SELECT CId FROM  course WHERE TId IN
                                                                      (SELECT TId FROM teacher WHERE Tname="张三")));
# 7. 查询没有学全所有课程的同学的信息
SELECT *
FROM student
WHERE SId in
  (SELECT student.SId
  FROM student LEFT JOIN
    (SELECT SId,COUNT(score) AS COUNT FROM sc GROUP BY (sc.SId))
      AS t1 ON t1.SId=student.SId
  WHERE COUNT<3 or COUNT IS NULL);
# 8. 查询至少有一门课与学号为" 01 "的同学所学相同的同学的信息
SELECT * FROM student WHERE SId IN (SELECT SId FROM sc WHERE CId in(SELECT CId FROM sc WHERE sc.SId=01) GROUP BY sc.SId );
# 9. 查询和" 01 "号的同学学习的课程 完全相同的其他同学的信息
SELECT *
FROM student
WHERE  SId in
       (SELECT DISTINCT t1.SId
       FROM sc AS t1 ,sc AS t2
       WHERE t1.SId!=t2.SId AND t2.SId=1 AND t1.CId=t2.CId
       GROUP BY t1.SId
       HAVING COUNT(t1.SId)=
              (SELECT COUNT(sc.score) FROM sc WHERE sc.SId=1));

select *
from student
where student.SId not in (
select t1.SId
from
(select student.SId,t.CId
from student ,(select sc.CId from sc where sc.SId='01') as t )as t1
left join sc on t1.SId=sc.SId and t1.CId=sc.CId
where sc.CId is null )
and student.SId !='01'
# 10. 查询没学过"张三"老师讲授的任一门课程的学生姓名
SELECT * FROM  student WHERE  SId NOT IN (SELECT SId FROM sc WHERE CId IN (SELECT  CId FROM course WHERE TId = (SELECT TId FROM teacher WHERE Tname="张三")));
# 11. 查询两门及其以上不及格课程的同学的学号，姓名及其平均成绩
SELECT student.*,AVG(score)
FROM student,sc
WHERE sc.SId=student.SId AND student.SId IN
                             (SELECT sc.SId FROM sc WHERE score<60 GROUP BY sc.SId  HAVING COUNT(sc.SId)>=2 )
GROUP BY sc.SId;
# 12. 检索" 01 "课程分数小于 60，按分数降序排列的学生信息
SELECT * FROM student,sc WHERE  sc.SId=student.SId AND CId=01 AND score<60 ORDER BY score DESC ;
# 13. 按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩
SELECT student.SId,student.Sname,t4.count,t1.score AS S1,t2.score AS S2,t3.score AS S3,t4.avg
FROM student LEFT JOIN
     (SELECT SId,score FROM sc WHERE  CId=1) AS t1 ON t1.SId=student.SId LEFT JOIN
     (SELECT  SId,score FROM sc WHERE  CId=2) AS t2 ON t2.SId=student.SId LEFT JOIN
     (SELECT SId,score FROM sc WHERE  CId=3) AS t3 ON t3.SId=student.SId LEFT JOIN
     (SELECT COUNT(score) AS count , AVG(score) AS avg ,SId FROM sc GROUP BY SId ) AS t4 ON t4.SId=student.SId ORDER BY avg DESC;
# 14. 查询各科成绩最高分、最低分和平均分：
SELECT SId,MAX(score) AS high,MIN(score) as low,AVG(score) AS avg FROM sc GROUP BY CId;
# 以如下形式显示：课程 ID，课程 name，最高分，最低分，平均分，及格率，中等率，优良率，优秀率
SELECT course.CId ,Cname ,MAX(score) AS high,MIN(score) AS low ,AVG(score) AS avg ,
       COUNT(CASE WHEN score>=60 THEN 1 END) / COUNT(1) pass_rate ,
       COUNT(CASE WHEN score<80 AND score>=70 THEN 1 END )/COUNT(1) middle_rate ,
       COUNT(CASE WHEN score<90 AND score>=80 THEN 1 END )/COUNT(1) good_rate,
       COUNT(CASE WHEN score>=90 THEN  1  END )/COUNT(1)  perfect_rate
FROM  sc,course
WHERE sc.CId=course.CId
GROUP BY sc.CId;
#及格为>=60，中等为：70-80，优良为：80-90，优秀为：>=90

# 要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排列
SELECT CId,COUNT(score) AS num
FROM sc
GROUP BY CId
ORDER BY num,CId;
# 15. 按各科成绩进行排序，并显示排名， Score 重复时保留名次空缺
SELECT sc.* ,
       ( CASE
         WHEN @count:=@count+1 THEN
         CASE
         WHEN @Cid = sc.CId  THEN
        (CASE
          WHEN @score  = sc.score THEN  @rank
         WHEN @score := sc.score THEN  @rank := @count
          END)
         WHEN @Cid := sc.CId  THEN @count:=1
         END
         END) rank_
FROM sc,(SELECT @rank:=0 , @score = null , @count :=0 ,@Cid :="01") as a
ORDER BY CId, sc.score desc
# 15.1 按各科成绩进行排序，并显示排名， Score 重复时合并名次
SELECT sc.*
       ,( CASE
         WHEN @Cid = sc.CId  THEN
        (CASE
          WHEN @score  = sc.score THEN  @rank
         WHEN @score := sc.score THEN  @rank := @rank+1
          END)
         WHEN @Cid := sc.CId  THEN @`rank`:=1
         END ) rank_
FROM sc,(SELECT @rank:=0 , @score = NULL,@Cid :="01") as a
ORDER BY CId, sc.score desc;
# 16. 查询学生的总成绩，并进行排名，总分重复时保留名次空缺
select t1.*,@currank:= @currank+1
from (select sc.SId, sum(score)
from sc
GROUP BY sc.SId
ORDER BY sum(score) desc) as t1,(select @currank:=0) as t;
# 16.1 查询学生的总成绩，并进行排名，总分重复时不保留名次空缺
select t1.*, (case when @fontscore=t1.sumscore then @currank  when @fontscore:=t1.sumscore  then @currank:=@currank+1  end ) as rank_
from (select sc.SId, sum(score) as sumscore
from sc
GROUP BY sc.SId
ORDER BY sum(score) desc) as t1,(select @currank:=0,@fontscore:=null) as t
# 17. 统计各科成绩各分数段人数：课程编号，课程名称，[100-85]，[85-70]，[70-60]，[60-0] 及所占百分比
SELECT sc.CId , Cname ,
       COUNT(CASE WHEN score< 60 THEN 1 END )/COUNT(1) 60_0,
       COUNT(CASE WHEN score>=60 AND  score<70 THEN 1 END )/COUNT(1) 70_60 ,
       COUNT(CASE WHEN score>=70 AND  score<85 THEN 1 END )/COUNT(1) 85_70 ,
       COUNT(CASE WHEN score>=85 AND  score<=100 THEN 1 END )/COUNT(1) 100_85
FROM sc,course
WHERE sc.CId=course.CId
GROUP BY sc.CId;
# 18. 查询各科成绩前三名的记录
SELECT *
FROM sc
WHERE (SELECT COUNT(*) FROM  sc AS a WHERE sc.CId=a.CId AND sc.score<a.score)<3
ORDER BY sc.CId ASC , sc.score DESC ;
# 19. 查询每门课程被选修的学生数
SELECT sc.CId,Cname,COUNT(score)
FROM sc LEFT JOIN course ON sc.CId=course.CId
GROUP BY sc.CId;
# 20. 查询出只选修两门课程的学生学号和姓名
SELECT student.SId,Sname
FROM student LEFT JOIN sc ON sc.SId=student.SId
WHERE sc.SId IN (
  SELECT sc.SId
  FROM sc
  GROUP BY sc.SId
  HAVING COUNT(score)=2);
# 21. 查询男生、女生人数
SELECT COUNT(CASE WHEN Ssex="男" THEN 1 END) 男,
       COUNT(CASE WHEN Ssex="女" THEN 1 END) 女
FROM student;
# 22. 查询名字中含有「风」字的学生信息
SELECT *
FROM student
WHERE Sname LIKE "%风%";
# 23. 查询同名同性学生名单，并统计同名人数
SELECT Sname,COUNT(Sname) AS names
FROM student
GROUP BY Sname
HAVING names>1;
# 24. 查询 1990 年出生的学生名单
SELECT *
FROM student
WHERE Year(Sage)=1990;
# 25. 查询每门课程的平均成绩，结果按平均成绩降序排列，平均成绩相同时，按课程编号升序排列
SELECT CId,AVG(sc.score) AS avg
FROM sc
GROUP BY CId
ORDER BY avg ;
# 26. 查询平均成绩大于等于 85 的所有学生的学号、姓名和平均成绩
SELECT student.*,AVG(sc.score) AS  avg
FROM sc,student
WHERE sc.SId=student.SId
GROUP BY sc.SId
HAVING avg>85;
# 27. 查询课程名称为「数学」，且分数低于 60 的学生姓名和分数
SELECT student.Sname,score
FROM student LEFT JOIN sc ON student.SId=sc.SId LEFT JOIN course ON sc.CId=course.CId
WHERE Cname="数学" AND score<60;
# 28. 查询所有学生的课程及分数情况（存在学生没成绩，没选课的情况）
SELECT student.SId,student.Sname,
       SUM(CASE WHEN CId=01 THEN score END ) 语文,
       SUM(CASE WHEN CId=02 THEN score END )数学,
       SUM(CASE WHEN CId=03 THEN score END )英语,
FROM student LEFT JOIN sc ON sc.SId=student.SId
GROUP BY Sname;
# 29. 查询任何一门课程成绩在 70 分以上的姓名、课程名称和分数
SELECT Sname,Cname,score
FROM student LEFT JOIN sc ON  sc.SId=student.SId LEFT JOIN course ON sc.CId=course.CId
WHERE score>70;
# 30. 查询不及格的课程
SELECT student.SId,Sname,CId,score
FROM student LEFT JOIN sc ON sc.SId=student.SId
WHERE score<60;
# 31. 查询课程编号为 01 且课程成绩在 80 分以上的学生的学号和姓名
SELECT student.SId,Sname
FROM student LEFT JOIN sc ON sc.SId=student.SId
WHERE CId="01" AND  score>=80;
# 32. 求每门课程的学生人数
SELECT CId,COUNT(score)
FROM sc
GROUP BY CId;
# 33. 成绩不重复，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩
SELECT student.SId ,score
FROM student,sc,course,teacher
WHERE sc.SId=student.SId AND sc.CId=course.CId AND course.TId=teacher.TId and Tname="李四"
ORDER BY score DESC
LIMIT 1,1;
# 34. 成绩有重复的情况下，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩
SELECT student.SId , score
FROM student,sc,course,teacher
WHERE sc.SId=student.SId AND sc.CId=course.CId AND course.TId=teacher.TId and Tname="李四" AND score =(
  SELECT MAX(score)
  FROM sc,course,teacher
  WHERE  sc.CId=course.CId AND course.TId=teacher.TId and Tname="李四"
  );
# 35. 查询不同课程成绩相同的学生的学生编号、课程编号、学生成绩
SELECT DISTINCT a.*
FROM sc AS a , sc AS b
WHERE a.SId=b.SId AND a.CId!=b.CId AND a.score=b.score;
# 36. 查询每门功成绩最好的前两名
SELECT *
FROM sc
WHERE (SELECT COUNT(*) FROM sc AS a WHERE a.CId=sc.CId AND sc.score<a.score)<2
ORDER BY CId ASC, sc.score DESC  ;
# 37. 统计每门课程的学生选修人数（超过 5 人的课程才统计）。
SELECT CId,COUNT(score)
FROM sc
GROUP BY CId
HAVING COUNT(score)>=5;
# 38. 检索至少选修两门课程的学生学号
SELECT SId
FROM sc
GROUP BY SId
HAVING COUNT(score)>=2;
# 39. 查询选修了全部课程的学生信息
SELECT SId
FROM sc
GROUP BY SId
HAVING COUNT(score)=3;
# 40. 查询各学生的年龄，只按年份来算
SELECT Sname, (YEAR(NOW()) - YEAR(Sage)) AS age
FROM student;
# 41. 按照出生日期来算，当前月日 < 出生年月的月日则，年龄减一
SELECT * , IF((MONTH(NOW()) > MONTH(Sage) AND DAY(NOW())>DAY(Sage)),(YEAR(NOW())-YEAR(Sage)),(YEAR(NOW())-YEAR(Sage))-1) AS age
FROM student;
# 42. 查询本周过生日的学生
SELECT *
FROM student
WHERE WEEKOFYEAR(Sage)=WEEKOFYEAR(NOW());
# 43. 查询下周过生日的学生
SELECT *
FROM student
WHERE WEEKOFYEAR(Sage)=WEEKOFYEAR(NOW())+1;
# 44. 查询本月过生日的学生
SELECT *
FROM student
WHERE MONTH(Sage)=MONTH(NOW());
# 45. 查询下月过生日的学生
SELECT *
FROM student
WHERE MONTH(Sage)=MONTH(NOW())+1;
