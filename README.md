Movie2(Ruby)
=================================================
    
    Author:Hao Wang (haowang@brandeis.edu)
    Date:1/31/2017
    This is my Ruby assignment in COSI166B course.
 
###Requirement
<http://cosi166b-s2017.s3-website-us-west-2.amazonaws.com/content/topics/pa/pa_movies_2.md/>

###CodeClimate:
<https://codeclimate.com/github/whorace/movie_2/issues>

###GitHub Repo:
<https://github.com/whorace/movie_2>

---

###Algorithm:
At first, I used the Cosine Similarity ( https://en.wikipedia.org/wiki/Cosine_similarity ) to get the similarity of each user. Xn is a movie_id. Yn is the corresponding rating of Xn.


And I sort the users in the decreasing order of their similarities. When I try to predict a movie rating of User A, I will find the rating of User B who has watched the movie and who also is the nearest. It is most likely that User B’s rating relating to the movie is the same as User A’s.

* Advantage:
the Cosine Similarity is very reliable.

* Drawback:
the accuracy will depend on the quantity of users. For example, we try to predict the User A’s rating about Movie A. If User A has many similar users with the closest similarity, we can easily get a similar user who has watched Movie A. Otherwise, if we cannot find a similar user who has watched it nearby, you have expanded the search scope and finally will find a user who has watched it but who has a big difference in the similarity with User A.

---

###Analysis:
I think the method is very qualified and usable. The difference between the prediction and the real situation is very close.

###Benchmarking:
In my test, the running time is less than 1 second. If the data increases 10 times or 100 times, I think the running time will increaser also with 10 times or 100 times.
