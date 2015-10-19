<div class="row collapse scoring-container">
    <div class="large-4 small-4 columns aggregated-score">
        <h4><%= scoring.get('score') %></h4>
        <p>Score</p>
    </div>
    <div class="large-4 small-4 columns subscribed-score">
        <h4><%= scoring.get('subscribed') %></h4>
        <p>Subscribed</p>
    </div>
    <div class="large-4 small-4 columns num-votes">
        <h4><%= scoring.get('num_votes') %></h4>
        <p>Votes</p>
    </div>
</div>