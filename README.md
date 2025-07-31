<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a id="readme-top"></a>


<!-- PROJECT SHIELDS -->

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]




<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/KevinTripi/Hey-Kevin">
    <img src="images/heykevin.png" alt="Logo" width="120" height="120">
  </a>

<h3 align="center">Hey-Kevin</h3>

  <p align="center">
    A Humorous Object Recognition App
    <br />
    <a href="https://drive.google.com/drive/folders/16Zp6c5n6LVZwTteA5Zw7Dv5zaW0CiTs5?usp=sharing"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://drive.google.com/drive/folders/1bquq4kAwfwjlW2fYbMneb8t5RZKvGxfi?usp=sharing">View Demo</a>
    &middot;
    <a href="https://github.com/KevinTripi/Hey-Kevin/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    &middot;
    <a href="https://github.com/KevinTripi/Hey-Kevin/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
        <li><a href="#gui">GUI</a></li>
        <li><a href="#server-workflow">Server Workflow</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

<!-- [![Product Name Screen Shot][product-screenshot]] -->

**Hey Kevin** is a mobile application that provides an entertaining twist to traditional object detection. The app allows users to capture images of objects, analyze them using **computer vision models**, and receive AI-generated humorous descriptions.

This project explores the integration of **advanced object segmentation, web-based search APIs, and natural language generation** to enhance user engagement in a playful yet technically sophisticated way.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



### Built With

* [![Flutter][Flutter.dev]][Flutter-url]
* [![Anthropic][Anthropic.com]][Anthropic-url]
* [![Docker][Docker.com]][Docker-url]
* [![FastAPI][FastAPI.com]][FastAPI-url]
* [![OpenCV][OpenCV.org]][OpenCV-url]
* [![Firebase][Firebase.com]][Firebase-url]
* [![Bing][Bing.com]][Bing-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### GUI
<img src="images/screenshot_1.jpg" alt="Screenshot 1" width="400">
<img src="images/screenshot_2.jpg" alt="Screenshot 2" width="400">
<img src="images/screenshot_3.jpg" alt="Screenshot 3" width="400">
<img src="images/screenshot_4.jpg" alt="Screenshot 4" width="400">

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Architecture

![Hey Kevin Architecture Diagram][architecture]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->
## Getting Started

To get started, you will need to clone and run the **[hey-kevin-backend](https://github.com/EegArlert/hey-kevin-backend)** Docker container before running the app. You will also need Flutter SDK for the development platform you will use (iOS or Android).

### Prerequisites

* [Docker](https://www.docker.com/get-started/)
* [Flutter](https://docs.flutter.dev/get-started/install)

### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/KevinTripi/Hey-Kevin.git
   ```
2. Build the Flutter app
    - Android:
      ```sh
      flutter build apk
      ```
    - iOS:
      ```sh
      flutter build iOS
      ```
3. Change git remote url to avoid accidental pushes to base project
   ```sh
   git remote set-url origin KevinTripi/Hey-Kevin
   git remote -v # confirm the changes
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Usage

* Connect your device and enter the command:
  ```sh
  flutter run
  ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>




<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Top contributors:

<a href="https://github.com/KevinTripi/Hey-Kevin/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=KevinTripi/Hey-Kevin" alt="contrib.rocks image" />
</a>



<!-- LICENSE -->
<!-- ## License

Distributed under the project_license. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>
 -->


<!-- CONTACT -->
## Contact

* Kevin Tripi - kevintripi@oakland.edu
* Christopher Castillo - ccastillo@oakland.edu
* Alex Russ - aruss@oakland.edu
* Dwight Valascho - dovalascho@oakland.edu
* Bill Syahputra - bsyahputra@oakland.edu
* Mara Salem - marasalem@oakland.edu
* Ammar Minhas - minhas@oakland.edu

Project Link: [https://github.com/KevinTripi/Hey-Kevin](https://github.com/KevinTripi/Hey-Kevin)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

* [Flutter Documentation](https://docs.flutter.dev/)
* [Bing Visual Search API](https://www.microsoft.com/en-us/bing/apis/bing-visual-search-api)
* [OpenCV Documentation](https://docs.opencv.org/4.x/index.html)
* [Ultralytics Segment Anything Model](https://docs.ultralytics.com/models/sam/)
* [FastAPI Tutorial](https://fastapi.tiangolo.com/tutorial/)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/KevinTripi/Hey-Kevin.svg?style=for-the-badge
[contributors-url]: https://github.com/KevinTripi/Hey-Kevin/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/KevinTripi/Hey-Kevin.svg?style=for-the-badge
[forks-url]: https://github.com/KevinTripi/Hey-Kevin/network/members
[stars-shield]: https://img.shields.io/github/stars/KevinTripi/Hey-Kevin.svg?style=for-the-badge
[stars-url]: https://github.com/KevinTripi/Hey-Kevin/stargazers
[issues-shield]: https://img.shields.io/github/issues/KevinTripi/Hey-Kevin.svg?style=for-the-badge
[issues-url]: https://github.com/KevinTripi/Hey-Kevin/issues
[Flutter.dev]: https://img.shields.io/badge/Flutter-blue?logo=flutter&amp;logoColor=white
[Flutter-url]: https://flutter.dev/
[OpenCV.org]: https://img.shields.io/badge/OpenCV-27338e?style=for-the-badge&logo=OpenCV&logoColor=white
[OpenCV-url]: https://opencv.org/
[OpenAI.com]: https://img.shields.io/badge/OpenAI-%23412991?logo=openai&logoColor=white
[OpenAI-url]: https://openai.com/
[Anthropic.com]: https://img.shields.io/badge/Claude-D97757?logo=claude&logoColor=fff
[Anthropic-url]: https://www.anthropic.com/
[Bing.com]: https://img.shields.io/badge/Microsoft%20Bing-258FFA?style=for-the-badge&logo=Microsoft%20Bing&logoColor=white
[Bing-url]: https://www.bing.com/visualsearch
[FastAPI.com]:https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi
[FastAPI-url]: https://fastapi.tiangolo.com/
[Firebase.com]: https://img.shields.io/badge/firebase-ffca28?style=for-the-badge&logo=firebase&logoColor=black
[Firebase-url]: https://firebase.google.com/
[Docker.com]: https://img.shields.io/badge/docker-257bd6?style=for-the-badge&logo=docker&logoColor=white
[Docker-url]: https://www.docker.com/
[product-screenshot1]: images/screenshot_1.jpg
[product-screenshot2]: images/screenshot_2.jpg
[product-screenshot3]: images/screenshot_3.jpg
[product-screenshot4]: images/screenshot_4.jpg
[architecture]: images/hey_kevin_architecture_diagram.png
