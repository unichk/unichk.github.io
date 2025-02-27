window.onload = function() {
  let date = new Date();
  date.setMonth(date.getMonth() - 1);
  Array.from(document.getElementById("articles").children).forEach(article => {
    let post_date = new Date(article.getElementsByClassName("date").item(0).textContent);
    if (post_date > date) {
      article.innerHTML = "<p class=\"new\">new!</p>" + article.innerHTML;
      console.log("new");
    }
  });
};