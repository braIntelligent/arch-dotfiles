// ==UserScript==
// @name         YouTube sin anuncios de video
// @description  Salta los anuncios que YouTube pone antes y durante los videos
// @match        https://www.youtube.com/*
// @match        https://music.youtube.com/*
// @run-at       document-end
// ==/UserScript==

// Los anuncios de video vienen del mismo servidor que el video, asi que el bloqueo
// por listas no los alcanza. Mientras el reproductor esta en modo anuncio
// ("ad-showing"), se adelanta el anuncio hasta el final y se aprieta "Saltar".
(function () {
    function saltar() {
        var reproductor = document.querySelector(".html5-video-player");
        if (!reproductor || !reproductor.classList.contains("ad-showing")) return;
        var video = reproductor.querySelector("video");
        if (video && isFinite(video.duration) && video.duration > 0) {
            video.muted = true;
            video.currentTime = video.duration;
        }
        var boton = document.querySelector(
            ".ytp-skip-ad-button, .ytp-ad-skip-button, .ytp-ad-skip-button-modern");
        if (boton) boton.click();
    }
    setInterval(saltar, 300);
})();
