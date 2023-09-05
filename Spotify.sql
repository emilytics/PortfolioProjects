SELECT *
FROM ['spotify-2023$']


-- 1. Top ARtists and Songs Analysis:
	-- Create a bar chart/table to visualize the top artists with the most streamed songs in 2023.

SELECT MAX(artist_count)
FROM ['spotify-2023$']
-- Max number of artists for one song in the dataset is 8

-- Create custom function to bypass built-in PARSENAME's 4 segment limit
CREATE FUNCTION dbo.CustomPARSENAME (
    @String NVARCHAR(MAX),
    @Delimiter CHAR(1),
    @Part INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @Result NVARCHAR(MAX)
    DECLARE @DelimiterCount INT

    -- Initialize variables
    SET @Result = NULL  -- Initialize to NULL
    SET @DelimiterCount = 0

    -- Loop through the string
    WHILE LEN(@String) > 0
    BEGIN
        SET @DelimiterCount = @DelimiterCount + 1
        DECLARE @NextDelimiterPosition INT
        SET @NextDelimiterPosition = CHARINDEX(@Delimiter, @String)

        IF @NextDelimiterPosition > 0
        BEGIN
            -- Found a delimiter, extract the part if it matches the requested part number
            IF @DelimiterCount = @Part
                SET @Result = SUBSTRING(@String, 1, @NextDelimiterPosition - 1)
            
            -- Remove the extracted part and delimiter from the string
            SET @String = SUBSTRING(@String, @NextDelimiterPosition + 1, LEN(@String) - @NextDelimiterPosition)
        END
        ELSE
        BEGIN
            -- No more delimiters, treat the whole string as the last part if it matches the requested part number
            IF @DelimiterCount = @Part
                SET @Result = @String
            
            -- Exit the loop
            BREAK
        END
    END

    RETURN @Result
END


-- Individual artists and number of songs they are credited in
WITH SplitArtistsCTE AS
(
	SELECT
		track_name,
		[artist(s)_name], 
		artist_count,
		dbo.CustomPARSENAME([artist(s)_name], ', ', 8) AS artist_8,
		dbo.CustomPARSENAME([artist(s)_name], ', ', 7) AS artist_7,
		dbo.CustomPARSENAME([artist(s)_name], ', ', 6) AS artist_6,
		dbo.CustomPARSENAME([artist(s)_name], ', ', 5) AS artist_5,
		dbo.CustomPARSENAME([artist(s)_name], ', ', 4) AS artist_4,
		dbo.CustomPARSENAME([artist(s)_name], ', ', 3) AS artist_3,
		dbo.CustomPARSENAME([artist(s)_name], ', ', 2) AS artist_2,
		dbo.CustomPARSENAME([artist(s)_name], ', ', 1) AS artist_1
	FROM ['spotify-2023$']
)
SELECT
	LTRIM(RTRIM(artist_1)) AS trimmed_artist,
	COUNT(artist_1) AS artist_count
FROM
(
	SELECT artist_1
	FROM SplitArtistsCTE
	UNION ALL
	SELECT artist_2
	FROM SplitArtistsCTE
	UNION ALL
	SELECT artist_3
	FROM SplitArtistsCTE
	UNION ALL
	SELECT artist_4
	FROM SplitArtistsCTE
	UNION ALL
	SELECT artist_5
	FROM SplitArtistsCTE
	UNION ALL
	SELECT artist_6
	FROM SplitArtistsCTE
	UNION ALL
	SELECT artist_7
	FROM SplitArtistsCTE
	UNION ALL
	SELECT artist_8
	FROM SplitArtistsCTE
) AS artist_list
WHERE artist_1 IS NOT NULL
GROUP BY LTRIM(RTRIM(artist_1))
ORDER BY artist_count DESC


-- Identify the most streamed songs and their characteristics (danceability, valence, energy, etc.).

SELECT
	TOP 100 track_name,
	[artist(s)_name],
	streams,
	bpm,
	[key]+' '+mode AS key_mode,
	[danceability_%],
	[energy_%],
	[acousticness_%],
	[instrumentalness_%],
	[liveness_%],
	[speechiness_%]
FROM ['spotify-2023$']
ORDER BY streams DESC



-- 2. Time Trends:
	-- Analyze whether there are any patterns in the release dates of popular songs.

SELECT
	TOP 100 track_name,
	[artist(s)_name],
	streams,
	CAST(CONVERT(NVARCHAR(4), [released_year]) + '-' + 
			 RIGHT('0' + CONVERT(NVARCHAR(2), [released_month]), 2) + '-' + 
			 RIGHT('0' + CONVERT(NVARCHAR(2), [released_day]), 2) AS DATE) AS release_date
FROM ['spotify-2023$']
ORDER BY streams DESC



-- 3. Correlation Analysis:
	-- Calculate correlations between song characteristics (e.g. danceability, valence, energy) and the number of streams.
		-- Visualize these correlations using scatter plots or correlation matrices.
		-- Identify which characteristics tend to make songs more popular.

SELECT
	track_name,
	[artist(s)_name],
	streams,
	bpm,
	[key]+' '+mode AS key_mode,
	[danceability_%],
	[energy_%],
	[acousticness_%],
	[instrumentalness_%],
	[liveness_%],
	[speechiness_%]
FROM ['spotify-2023$']
ORDER BY streams DESC



-- 4. Playlist and Chart Impact:
	-- Analyze the influence of being in Spotify, Apple Music, and Deezer playlists or charts on the number of streams.

SELECT
	track_name,
	[artist(s)_name],
	streams,
	in_spotify_playlists,
	in_spotify_charts,
	in_apple_playlists,
	in_apple_charts,
	in_deezer_playlists,
	in_deezer_charts,
	in_shazam_charts
FROM ['spotify-2023$']
ORDER BY streams DESC



-- 5. Audio Feature Distributions:
	-- Create histograms or box plots to visualize the distributions of audio features like BPM, key, and mode.

SELECT
	track_name,
	[artist(s)_name],
	streams,
	bpm,
	[key]+' '+mode AS key_mode
FROM ['spotify-2023$']