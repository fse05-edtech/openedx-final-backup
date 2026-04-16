// Kurslardaki başlık ve description alanını kısaltmak için

$(document).ready(() => {
  $(".course-description").each((index, i) => {
    if (i.innerText.length == 0 || i.innerText === "None") {
      i.innerText =
        "Kısa Tanım Alanı. Studio'dan bu alana ders ile ilgili kısa bir tanım yazabilirsiniz.";
      return;
    }
    if (i.innerText.length < 150) {
      return;
    }
    i.innerText = i.innerText.substr(0, 150) + "...";
  });

  $(".course-title").each((index, i) => {
    if (i.innerText.length > 50) {
      i.innerText = i.innerText.substr(0, 47) + "...";
      return;
    }
  });
});
