<template>
  <ListView :style="appBackgroundColor" ref="listView" for="podcast in podcasts" @itemTap="onPodcastTap" separatorColor="transparent">
    <v-template>
      <StackLayout width="100%" class="p-x-10 p-y-10">
        <FlexboxLayout orientation="horizontal" justifyContent="space-between" flexWrap="nowrap">
          <ActivityIndicator v-show="podcast.playing === 'loading'" busy="true" flexShrink="0" :style="primaryTextColor" alignSelf="flex-start" width="30" fontSize="30"/>
          <Label :text="'\ue038'" v-show="podcast.playing === 'paused'" flexShrink="0" :style="primaryTextColor" class="mdi" width="30" fontSize="30" />
          <Label :text="'\ue034'" v-show="podcast.playing === 'playing'" flexShrink="0" :style="primaryTextColor" class="mdi" width="30" fontSize="30"/>
          <Label :text="podcast.title" :style="primaryTextColor" class="p-l-5" flexGrow="2" flexShrink="2" fontWeight="300" textWrap="true"/>
          <Label :text="podcast.duration" :style="secondaryTextColor" class="pull-right bold m-r-5" width="30" flexShrink="0" fontSize="9" opacity="0.4" alignSelf="flext-end"/>
        </FlexboxLayout>
        <Label :text="podcast.content" :style="secondaryTextColor" opacity="0.6" padding="8 0 8 35" fontWeight="300" fontSize="11" width="100%" textWrap="true"/>
        <StackLayout width="100%" paddingLeft="30">
          <StackLayout width="100%" height="1" :style="primaryTextColor" class="m-t-10" opacity="0.3"></StackLayout>
        </StackLayout>
      </StackLayout>
    </v-template>
  </ListView>
</template>
<script>
import PodcastService from '../api/PodcastService'
import htmlToText from 'html-to-text'
import { SET_PLAYER_SCREEN, PLAY_URL, PAUSE } from '../store/constants'
import config from '../config.js'

const {
  colors: {
    primaryText: primaryTextColor,
    secondaryText: secondaryTextColor,
    appBackgroundColor
  }
} = config

export default {
  data: () => {
    return {
      primaryTextColor,
      secondaryTextColor,
      appBackgroundColor,
      podcasts: []
    }
  },
  mounted () {
    PodcastService.getPodcasts(30).then((podcasts) => {
      this.podcasts = podcasts.data.results.map((podcast) => {
        podcast.playing = 'paused'
        podcast.content = htmlToText.fromString(podcast.content, { wordwrap: 200 })
        return podcast
      })
    }).catch((err) => console.log(err))
  },
  computed: {
    player_screen () {
      return this.$store.getters.getPlayerScreen
    }
  },
  watch: {
    player_screen (newPlayerScreen) {
      if (newPlayerScreen !== 'PODCAST') {
        this.pauseAll()
      }
    }
  },
  methods: {
    play (podcast) {
      this.$store.commit(SET_PLAYER_SCREEN, 'PODCAST')
      podcast.playing = 'loading'
      this.$store.commit(PLAY_URL, podcast.file_download)
      this.$store.getters.getPlayPromise.then((res) => {
        podcast.playing = 'playing'
      })
        .catch(() => {
          this.pause(podcast)
          alert({
            title: this.$t('error'),
            message: this.$t('thereWasAProblemPlayingThisPodcast'),
            okButtonText: this.$t('understood')
          })
        })
    },
    pause (podcast) {
      podcast.playing = 'paused'
    },
    pauseAll () {
      this.podcasts.map(podcast => this.pause(podcast))
    },
    onPodcastTap (event) {
      this.$store.commit(PAUSE)
      let willPlay = false
      if (event.item.playing === 'paused') {
        willPlay = true
      }
      this.pauseAll()
      if (willPlay) {
        this.play(event.item)
      }
    }
  }
}
</script>
