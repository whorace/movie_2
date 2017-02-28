class ClassRating
  def initialize(sourceFile)
    @sourceFile = sourceFile
    @user_movieAndRating = Hash.new #{user_id, movie_id1 rating1 movie_id2 rating2}
    @user_similarityRating = Hash.new #{user_id, similarity rating}
    #@user_sortedSimilarityRating = Hash.new #{user_id, similarity rating}
    @user_indexOfArray = Hash.new #{user_id,indexOfArray}
    @user_sortedMovieAndRating = Array.new #{user_id, similarity_rating, movie_id1 rating1 movie_id2 rating2}sort by similarity rating
  end

  #result is @user_movieAndRating
  def load_data
    # read data in souce data
    sourceFile = File.open(@sourceFile,"r")
    # read line by line
    sourceFile.each_line do |line|
      #puts line
      arr=line.strip.split( "\s")
      #puts arr
      user_id = arr[0]
      movie_id = arr[1]
      rating = arr[2]
      #timestamp = arr[3]

      addUserWithMovieAndRating(user_id, movie_id, rating)

    end

  end#end of load_data()

  def addUserWithMovieAndRating(user_id, movie_id, rating)
    if @user_movieAndRating[user_id] == nil
      @user_movieAndRating[user_id] = "#{movie_id} #{rating}"
    else
      str = @user_movieAndRating[user_id]
      str << " #{movie_id} #{rating}"
      @user_movieAndRating[user_id] = str
    end
  end#end addUserWithMovieAndRating()

  def addUserWithSimilarityrating(user_id, similarity_rating)
    @user_similarityRating[user_id] = similarity_rating
  end#end addUserWithSimilarityrating()

  def addUserWithSortedSimilarityrating(user_id, similarity_rating)
    @user_sortedSimilarityRating[user_id] = similarity_rating
  end#end addUserWithSortedSimilarityrating()

  def addUserWithIndexOfArray(user_id, index)
    @user_indexOfArray[user_id] = index
  end #end addUserWithIndexOfArray()

  def addUserWithSortedMovieAndRating(user_id, similarity_rating, movieAndRating)
    movieAndRatingObj = MovieAndRating.new
    movieAndRatingObj.user_id = user_id
    movieAndRatingObj.similarity_rating = similarity_rating
    movieAndRatingObj.movieAndRating = movieAndRating
    @user_sortedMovieAndRating << movieAndRatingObj
  end
  # traverse all users and caculater the cos smilarity
  # COS=(X1Y1 + X2Y2 +...+XNYN)/SQRT(Y1^2+Y2^2+...+YN^N)*SQRT(X1^2+...XN^N)
  # result is @user_similarityRating
  def getTheSimilarityRating
    @user_movieAndRating.each do |key, value|
      arr = value.strip.split("\s")
      i = 0
      movie_id = nil
      rating = nil
      sumOfXY = 0
      sumofYY = 0
      sumOfXX = 0
      arr.each do |element|
        if i % 2 ==0
          movie_id = element
        else
          rating = element
          sumOfXY += movie_id.to_f * rating.to_f
          sumofYY += rating.to_f * rating.to_f
          sumOfXX += movie_id.to_f * movie_id.to_f
        end
        i += 1

      end#end of loop arr
      # sumOfXX is all the same, ignore it.
      cos = (sumOfXY / (Math.sqrt(sumOfXX) * Math.sqrt(sumofYY))).round(1)

      addUserWithSimilarityrating(key, cos)#key is user_id
    end#end of loop @user_movieAndRating
  end#end of getTheSimilarityRating()

  def sortValueInHash()
    index = 0
    @user_similarityRating.sort{|a,b|b[1]<=>a[1]}.each do |element|

      #addUserWithSortedSimilarityrating(element[0],element[1])

      addUserWithIndexOfArray(element[0], index)

      movieAndRating = @user_movieAndRating[element[0]]
      addUserWithSortedMovieAndRating(element[0], element[1], movieAndRating)

      index += 1
    end
  end#end of sortValueInHash

 #  def saveData
 #   saveFile = open("user_similarityRating.txt","w")
 #   saveFile.truncate(0)
 #   @user_sortedSimilarityRating.each do |key,value|
 #     saveFile.write("#{key}|#{value}")
 #     saveFile.write("\n")
 #   end
 # end#end of saveData()

 def predict(user, movie_id)
   rating = nil
   #puts @user_indexOfArray
   index = @user_indexOfArray[user.to_s]
   if index == nil
     puts "doesn't find the user_id"
   else

    object = @user_sortedMovieAndRating.at(index)
    movieAndRating = object.movieAndRating
    check = checkMovieInTheStringOfMovieAndRatingHelper(movie_id, movieAndRating)
    if check == -1
      notFound = true
      left = index - 1
      right = index + 1
      similarUser = nil
      while notFound && left >= -1 && right <= @user_sortedMovieAndRating.length do
        #puts "check"
        # index is 0
        if left == -1
          movieAndRating = @user_sortedMovieAndRating.at(right).movieAndRating
          check = checkMovieInTheStringOfMovieAndRatingHelper(movie_id, movieAndRating)
          if check == -1
            right += 1

          else
            notFound = false
            #puts "check:found"
            similarUser = @user_sortedMovieAndRating.at(right).user_id
          end
        # index is equal to the length
        elsif right == @user_sortedMovieAndRating.length
          movieAndRating = @user_sortedMovieAndRating.at(left).movieAndRating
          check = checkMovieInTheStringOfMovieAndRatingHelper(movie_id, movieAndRating)
          if check == -1
            left -= 1

          else
            notFound = false
            #puts "check:found"
            similarUser = @user_sortedMovieAndRating.at(left).user_id
          end

        elsif (@user_sortedMovieAndRating.at(left).similarity_rating - @user_sortedMovieAndRating.at(index).similarity_rating).abs < (@user_sortedMovieAndRating.at(index).similarity_rating - @user_sortedMovieAndRating.at(right).similarity_rating).abs
          #puts "check:left side"
          movieAndRating = @user_sortedMovieAndRating.at(left).movieAndRating
          check = checkMovieInTheStringOfMovieAndRatingHelper(movie_id, movieAndRating)
          if check == -1
            left -= 1

          else
            notFound = false
            #puts "check:found"
            similarUser = @user_sortedMovieAndRating.at(left).user_id
          end
        else
          #puts "check:right side"
          movieAndRating = @user_sortedMovieAndRating.at(right).movieAndRating
          check = checkMovieInTheStringOfMovieAndRatingHelper(movie_id, movieAndRating)
          if check == -1
            right +=1

          else
            notFound = false
            #puts "check:found"
            similarUser = @user_sortedMovieAndRating.at(right).user_id
          end

        end#end of if loop

      end#end of while loop
      if check == -1
        puts "Cannot predict"
      else
        rating = check
        puts "#{user} may rate #{rating} as same as #{similarUser}"
      end

    else
      rating = check
      puts "#{user} has watched the movie with rating #{rating}"
    end#end of if statement


  end#end of if statement when index is nil

end#end of predict()



 def checkMovieInTheStringOfMovieAndRatingHelper (movie_id, line)
   #puts "check: string"
   arr = divideStringToArrayHelper(line)
   check = checkMovieInTheArrHelper(arr, movie_id)
   return check
 end

 # not found return -1; found return rating
 def checkMovieInTheArrHelper(arr, movie_id)
   #puts "check: array"
   index = 0
   arr.each do |element|
     if (index % 2 == 0) && (movie_id.to_s == element.to_s)# take care of the datatype of checking
       #puts "Found"
       return arr.at(index + 1)

     end
     index += 1
   end
   return -1

 end

 def divideStringToArrayHelper(line)
   #puts "check: divide"
   arr = line.strip.split("\s")
   #puts arr
   return arr
 end


end
#end of class ClassRating

#using for creating the array object of @user_sortedMovieAndRating
class MovieAndRating
  attr_accessor(:user_id, :similarity_rating, :movieAndRating)
end

class Validator
  def initialize(baseFile, testFile)
    @baseFile = baseFile
    @testFile = testFile

  end
  def runBase(user_id, movie_id)
    u1Base = ClassRating.new(@baseFile)
    u1Base.load_data
    u1Base.getTheSimilarityRating
    u1Base.sortValueInHash
    puts "**********************"
    puts "      Base File"
    u1Base.predict(user_id,movie_id)


  end
  def runTest(user_id, movie_id)
    u1Test = ClassRating.new(@testFile)
    u1Test.load_data
    u1Test.getTheSimilarityRating
    u1Test.sortValueInHash
    puts "**********************"
    puts "      Test File"
    u1Test.predict(user_id,movie_id)


  end
end

class Control
  def run
    puts "Base File is u1.base."
    puts "Test File is u1.test."
    vilidator = Validator.new("u1.base", "u1.test")
    puts "user_id is 1. movie_id is 6"
    puts Time.now
    vilidator.runBase(1, 6)
    vilidator.runTest(1, 6)
    puts Time.now
  end


end

control = Control.new
control.run
