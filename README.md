<p align="center" style="padding-top:20px">
<h1 align="center">Starfield</h1>
<p align="center">High performance particle system for Flutter</p>

<p align="center">
    <a href="https://matrix.to/#/#commet:matrix.org">
        <img alt="Matrix" src="https://img.shields.io/matrix/commet%3Amatrix.org?logo=matrix">
    </a>
    <a href="https://fosstodon.org/@commetchat">
        <img alt="Mastodon" src="https://img.shields.io/mastodon/follow/109894490854601533?domain=https%3A%2F%2Ffosstodon.org">
    </a>
    <a href="https://twitter.com/intent/follow?screen_name=commetchat">
        <img alt="Twitter" src="https://img.shields.io/twitter/follow/commetchat?logo=twitter&style=social">
    </a>
</p>

Existing particle systems for Flutter store particles as individual objects, which makes them slower to iterate over and process. Starfield takes a data-oriented approach, storing each particle attributes in contiguous memory allowing them to be processed much more efficiently. This has the added bonus of not needing to do any further processing at render time, as the renderer can read these memory buffers directly.