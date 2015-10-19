
{# Section w/ tabs + slideshow #}

{# Requires additional JS + CSS #}

<link rel="stylesheet" href="{{ root }}css/page-specific/constituents-coalition-story.css">
<script type="text/javascript" src="{{ root }}js/vendor/slick.min.js"></script>
<link rel="stylesheet" href="{{ root }}css/vendor/slick.css">

<style>

div.main-content.row div.menu-label {
  list-style: none; 
  padding: 0.8rem 2rem 0; 
  font-size: 1.2rem;
}

div.main-content.row ul.menu-front-tabs li a h5 {
  margin: 0;
}

div.main-content.row div#main-tab-content > section.content {
  background: #fff;
  padding-left: 24px;
  padding-right: 24px;  
  padding-top: 18px;
}
</style>

<div class="row">

    <div class="medium-4 columns menu-label text-left" role="presentation">
        <b><em>{{ site_name }} is for</em></b>
    </div>

    <div class="medium-8 columns">
        <ul class="tabs row collapse menu-front-tabs" data-tab role="tablist">
            <li class="tab-title medium-6 columns text-center active" role="presentation" style="border-right: 1px solid #ddd;">
                <a href="#panel1-for-constituents" role="tab" tabindex="0" aria-selected="true" aria-controls="panel1-for-constituents">
                    <h5>Citizens</h5>
                </a>
            </li>
            <li class="tab-title medium-6 columns text-center" role="presentation">
                <a href="#panel2-for-legislature" role="tab" tabindex="0" aria-selected="false" aria-controls="panel2-for-legislature">
                    <h5>Leaders</h5>
                </a>
            </li>
        </ul>
    </div>

</div>

<div id="main-tab-content" class="tabs-content" style="margin-bottom: 18px;">

    <section role="tabpanel" aria-hidden="false" class="content active" id="panel1-for-constituents">
        <h4>Build coalitions <span class="ext">around common causes; be represented</span></h4>

        {#
        <p>
          On average, there are over 750,000 constituents for each U.S. Representative &mdash; and growing. 
          At a scale this large and with time so valuable, getting face-time to discuss issues with a representative is almost unthinkable to many constituents.
          Effectively, large portions of constituencies are arguably under-represented in legislature.   
        </p>
        #}
        <p>
          Today, people habitually collaborate on-line to generate troves of information from which readily-accessible aggregates of popular opinion, preference, or understanding are the end product. 
          Reddit's front page consists of Reddit's most popular posts &mdash; those which the Reddit community as a whole has voted to be most interesting or appealing.
          Yelp and TripAdvisor produce aggregate ratings and rankings of popular consumer destinations near any particular location. 
          Wikipedia articles are the manifestations of consensuses of what contributors to those articles agree is the most correct and useful information regarding a particular topic.
        </p>
        <p>
          Why not adopt these mechanisms to improve representation of our interests within legislature and the integrity of our political system?
        </p>

        <h5 style="border-bottom: 1px solid #ddd; padding: 0 60px 8px; margin-bottom: 18px; text-align: center;">
          How to utilize <em>{{ site_name }}</em> <span class="ext">to start a coalition and produce legislative action</span>
        </h5>

        {# Comic Strip #}
        
        <div class="row collapse constituents-coalition-story">
        
          <div class="slick-slide">
            <img src="/img/large/user_story_sections/1.jpg">
            <span>
              Joe discovers that online poker, an activity which he enjoys, is outlawed in the United States.
            </span>
          </div>
          
          <div class="slick-slide">
            <img src="/img/large/user_story_sections/2.jpg">
            <span>
              Joe defines an issue on <em>{{ site_name }}</em> that makes his problem
              &mdash; not having access to online poker &mdash; take a visible & written form to become known to others.
            </span>
          </div>
          
          <div class="slick-slide">
            <img src="/img/large/user_story_sections/3.jpg" style="margin-top: 12px;">
            <span>
              Bill notices the issue regarding lack of access to online poker on <em>{{ site_name }}</em>
              and feels that he agrees that it is an important issue. 
              He votes 'up' for the issue, and contributes to the definition by adding some of his knowledge and references to the document.
            </span>
          </div>
        
          <div class="slick-slide"> 
            <img src="/img/large/user_story_sections/4.jpg" style="margin-top: 24px;">
            <span>
              Both Joe and Bill spread awareness of the issue through their social networks via conversations and social media platforms.
              Their friends notice, and perhaps agreeing on issue's importance, start to contribute to the issue definition, start a debate, propose a response, or vote on one.
              Communicating the group-formed issue definition to friends and acquaintances may be done as simply as distributing any link or URL.
            </span>
          </div>
          
          <div class="slick-slide">
            <img src="/img/large/user_story_sections/5.jpg" style="margin-top: 26px;">
            <span>
              As more people contribute, visibility of the issue regarding online poker legality grows from votes and views,
              the amount of users engaging with the issue cascades upwards. 
              A sort of article, which is the definition and supporting knowledge & references of an issue, begins to take coherent form.
              Responses begin to appear, voted on, and ranked. 
            </span>
          </div>
          
          <div class="slick-slide">
            <img src="/img/large/user_story_sections/6.jpg">
            <span>
              As the issue (and responses) mature and become more presentable, participants in issue definition's creation may 
              communicate the issue, via its URL, and along with its top response(s) &mdash; especially if the ideal response is legislative action &mdash;
              to their representatives.  
            </span>
            {#
            <div class="copy">
              As the issue (and responses) mature and become more presentable, participants in issue definition's creation may 
              communicate the issue, via its URL, and along with its top response(s) &mdash; especially if the ideal response is legislative action &mdash;
              to their representatives.  
            </div>
            #}
          </div>
          
        </div>

        <script>
        
          $(document).ready(function(){
          
            if (typeof ce == 'undefined') window.ce = {};
            window.ce.slidesContainer = $('.constituents-coalition-story');
            window.ce.slides = $('div.slick-slide');
          
            ce.slidesContainer.slick({
              infinite: false,
              slidesToShow: 2,
              slidesToScroll: 1,
              adaptiveHeight: true,
              prevArrow: '<div class="arrow previous slick-prev"><i class="fa fa-arrow-circle-o-left"></i></div>',
              nextArrow: '<div class="arrow next slick-next"><i class="fa fa-arrow-circle-o-right"></i></div>',
              responsive: [
                {
                  breakpoint: 1240,
                  settings: {
                    slidesToShow: 2
                  }
                },
                {
                  breakpoint: 1800,
                  settings: {
                    slidesToShow: 3
                  }
                }
              ]
            });
            
            function adjustSlideContainerHeight(nextSlide){
              var firstSlide = $(ce.slides[nextSlide]);
              var secondSlide = $(ce.slides[nextSlide + 1]);
              var thirdSlide = (function(){
                if ($(document.body).width() < 1800 && $(document.body).width() >= 1240) {
                  return $(ce.slides[nextSlide + 2]);
                } else return false;
              })();
              
              /** Finds max height of visible slides and applies it to parent slideshow container **/
              
              var maxHeight = _.max(_.map(
                [firstSlide, secondSlide, thirdSlide], 
                function(slide){
                  if (!slide) return 0;
                  return Math.max(
                    parseInt(slide.children('span').css('top')) + parseInt(slide.children('span').height()) + 15, 
                    parseInt(slide.outerHeight())
                  );
                }
              ));
              
              ce.slidesContainer.find('.slick-list').height(maxHeight);
              
              _.each(
                [firstSlide, secondSlide, thirdSlide],
                function(slide){
                  if (!slide) return;
                  var span = slide.children('span');
                  var spanTop = parseInt(span.css('top'));
                  if (typeof spanTop !== 'number' || spanTop == 0) return;
                  span.css('padding-bottom', maxHeight - spanTop + 7 + 'px');
                }
              );
              
            }
            
            function resize(){
              ce.slides.not('[data-slick-index="5"]').find('span').css('top', ce.slides.find('img').height() + 'px');
              adjustSlideContainerHeight(ce.slidesContainer.slick('slickCurrentSlide'));
            }
           
            var throttledTabResize = _.throttle(function (tab){
              if ($(tab[0]).attr('id') == 'panel1-for-constituents') {
                ce.slidesContainer.slick('setPosition');
                resize();
              }
            }, 250);
            
            /** Execution **/
            
            resize();
            
            /** Event Bindings **/
            
            $('ul.menu-front-tabs').on('toggled', function(event, tab) {
              throttledTabResize(tab);
            });
           
            ce.slidesContainer.on('beforeChange', function(event, slick, currentSlide, nextSlide){
              adjustSlideContainerHeight(nextSlide);
            });
            
            $(window).resize(function(){
              setTimeout(resize, 150);
            });
            
          });
          
          
          
        </script>

    </section>

    <section role="tabpanel" aria-hidden="true" class="content row collapse" id="panel2-for-legislature">
        <div class="columns large-2 medium-12 xlarge-12" style="border-bottom: 1px solid #ddd;">
            <p>
                Community leaders such as representatives, government officials, politicians, as well as entrepreneurs & business owners
                can benefit from a clearer image of what concerns their constituency the most, as well as various ideas for resolving those issues.
            </p>
        </div>
        <div class="columns large-10 medium-12 xlarge-12">
            <img src="/img/large/front_diagram_issues_sorted_3.jpg" class="primary">
        </div>
    </section>
</div>