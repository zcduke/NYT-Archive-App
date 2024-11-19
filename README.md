Sta 523 - Fall 2024 - Midterm 2
-----------

Due Monday, December 2nd by 5:00 pm

### Rules

1. Your solutions must be written up using the `midterm2.qmd` quarto document file, this file must include all of your code and write up for each task (except task 3, more details follow).

2. This exam is open book, open internet, closed other people. You may use *any* online or book based resource you would like, but you must include citations for any code that you use (directly or indirectly). You *may not* consult with anyone else about this exam other than the Professor or TAs for this course - this includes posting anything online.

3. You have until 5:00 pm on Monday, December 2nd to complete this exam and turn it in via your personal Github repo - late work will not be accepted without prior approval. Technical difficulties are not an excuse for late work - do not wait until the last minute to commit / push.

4. All of your answers must include a brief description / write-up of your approach. This includes both annotating / commenting your code *and* a separate written descriptions of all code / implementations. I should be able to suppress *all* code output in your document and still be able to read and make sense of your answers.

5. You may use any packages you want.

6. The most important goal is to write code that can accomplish the given tasks, note however that grading will be partially based on the quality of the code you write - elegant, efficient code will be rewarded and messy, slow code will be penalized.

---

### New York Times API

The NY Times has a number of useful and interesting [APIs](http://developer.nytimes.com/) that will let you explore the more than 150 years of articles, editorials, etc. from the paper. For this assignment we will specifically be using the [Article Search API](https://developer.nytimes.com/docs/articlesearch-product/1/overview) to pull metadata about NY Times articles throughout history.

To access this or any of the other API endpoints you will need to register with the NY Times [here](https://developer.nytimes.com/accounts/create). Once you have created and verified your account you can then create an App (using the menu under your email address) and enable access to the Article Search API. In creating this App you will be given an API key to authenticate yourself with when making API requests. You API key will be limited to at most 10 requests / minute and 4000 requests / day -  there is no reason that you should be anywhere near the daily limits but the per minute request limit is easy to hit - you will likely need to sleep (~6 seconds between calls) to avoid it (if you need to make more than 10 calls).

---

### Task 1 - Understanding the NY Times Article Search API

In the next task you will be writing a function to access articles for a specific day in history. The first thing you should do is review the Article Search API [documentation](https://developer.nytimes.com/docs/articlesearch-product/1/overview) and Lucene syntax [documentation](http://www.lucenetutorial.com/lucene-query-syntax.html) used for the filter query (`fq`) parameter. Note that the list of filter query fields in the documentation is not complete, as you can query most document entries in the responses (e.g. `print_page` and `print_section`) even if they are not explicitly listed.

To limit the number of results we get for any given date we will be filtering the results according to the following criteria.

* Results should be filtered to only contain documents published on the specified date.

* Results should be filtered to only contain article type documents.

* Results should be filtered to only contain documents from the front page of the paper (i.e. `print_page` is 1 and `print_section` is "A").

Due to some internal weirdness, searching for older articles using these criteria can be unreliable - as such you should test against a number of dates, but a failure (0 results returned) for certain dates before the 1980s is expected and acceptable. Note that for current dates we expect the API to return around 4-12 results per day.

Based on these requirements come up with a sample request URL to download the front page articles for your birthday in the first year you were enrolled in College. Include this complete URL in your `qmd` and describe each parameter value you've chosen in your API request. (If you did not use one of the parameters you can remove it from the list provided, not all parameters are necessary).

No write up is needed beyond the documentation of your URL parameters.

---

### Task 2 - Getting data from the NY Times Article Search API

Your next task is to write a function for retrieving article data from the NY Times Article Search API. Based on what you worked out about the API in the preceding task.

Your function should meet the following requirements:

* The function should take 4 arguments (in this exact order): `year`, `month`, `day`, and `api_key`

* The function should perform basic sanity checks on user inputs (e.g. 1 <= `month` <= 12, all values are of length 1, etc.) You do not need to verify the day of the month except to verify it is between 1 and 31.

* The function should return a tidy data frame containing *all* API results for that date. At a minimum you should include a headline, byline (author(s)), web url, lead paragraph, and source columns. You do not need to flatten all columns, list columns are acceptable when necessary / useful.

* The function must fetch *all* documents' metadata meeting the requirements from Task 1. Each API request will return only 10 documents at a time, if there are more than 10 matching documents you will need to make multiple requests using different values of the `page` parameter (note this is about API result pages and not pages of the newspaper). Your initial request will give you an exact number of matching documents which you can use to determine the number of requests to make. Requests should be timed so that the per minute rate limit is not exceeded, but also not taking longer than necessary.

* As mentioned above, some dates may return zero results - your function should handle these cases gracefully.

Make sure to include a brief write up describing your implementation, you should specifically discuss how pagination and timeouts are handled as well as how empty results are handled.

---

### Task 3 - Shiny Front End

Your third task is to create a Shiny app to provide a GUI interface for the `get_nyt_archive` function you wrote earlier. This app should allow the user to select a year, month, and day and view the headlines from that day.

Your app should have the following features:

* The app should be wholly implemented in the `midterm2.R` script file and not in the `qmd`. This script has code to load your `get_nyt_articles()` function from the `qmd`.

* The user should be able to specify year, month, and day in a sidebar panel. Default value should be set to your birth month, and day in the first year you attended college. You may use multiple inputs for each value or a signle `dateInput()`.

* The user should be able to supply their own API key. You are welcome to hard code your API key as the default value for this field.

* The sidebar should also include an action button that retrieves the API data, no requests to the API should be made unless this button is pressed.

* Once the button is clicked the main panel should display a *neatly* organized and formatted list of front page NY Times headlines for the specified date.
    
* The user should be able to click on any of the headlines and have a [modal dialog box](https://shiny.rstudio.com/reference/shiny/latest/modalDialog.html) pop up that contains the title, byline, and first paragraph of the article as well as a working link to the full article on nytimes.com.
    
* Extra credit will be given for the inclusion of any other interesting features returned by the API (e.g. including pictures / multimedia items in the modal dialog, avoid including duplicate items here if possible). 

The sample code includes some hints in terms of approaches that might be helpful in constructing your app. In particular, since the number of headlines for each date will change, we would like our UI to be dynamic. The included code shows how to make use of a `uiOutput` along with dynamically creating and destroying observers as necessary for reacting to link clicks. Note that this is a bare-bones sketch of an app. Feel free to use an alternative approach or UI design, you should make the final product as stylish and attractive as possible. Also note that the slider is included for illustrative purposes, your final app should determine the number of links to display based on the number of results (rows) from the API request - in other words, the final app should *not* have this slider in it.

If you find the included code confusing, I strongly recommend that you experiment with it before attempting to add any additional features. Try commenting out various lines and observe how the behavior changes (e.g. comment out the lines that destroy the observers, what happens if you adjust the slider to 2 and then click on link 1?). Adding addition print statements can also be a helpful way of understanding what is going on with the internals of the app.

Make sure to include a brief write up describing your implementation.

---
