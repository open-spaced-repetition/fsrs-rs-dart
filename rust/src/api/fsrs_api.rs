use std::sync::Mutex;

use crate::frb_generated::RustAutoOpaque;
use flutter_rust_bridge::frb;

#[frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

#[derive(Debug)]
#[frb(opaque)]
pub struct FSRS(Mutex<fsrs::FSRS>);
impl FSRS {
    #[frb(sync)]
    pub fn new(parameters: Vec<f32>) -> Self {
        Self(fsrs::FSRS::new(Some(&parameters)).unwrap().into())
    }
    #[frb(sync)]
    pub fn next_states(
        &self,
        current_memory_state: Option<MemoryState>,
        desired_retention: f32,
        days_elapsed: u32,
    ) -> NextStates {
        NextStates(
            self.0
                .lock()
                .unwrap()
                .next_states(
                    current_memory_state.map(|x| x.0.clone()),
                    desired_retention,
                    days_elapsed,
                )
                .unwrap()
                .into(),
        )
    }
    #[frb(sync)]
    pub fn compute_parameters(&self, train_set: &[FSRSItem]) -> Vec<f32> {
        self.0
            .lock()
            .unwrap()
            .compute_parameters(train_set.iter().map(|x| x.0.clone()).collect(), None, true)
            .unwrap_or_default()
    }
    #[frb(sync)]
    pub fn benchmark(&self, train_set: &[FSRSItem]) -> Vec<f32> {
        self.0
            .lock()
            .unwrap()
            .benchmark(train_set.iter().map(|x| x.0.clone()).collect(), true)
    }
    #[frb(sync)]
    pub fn memory_state_from_sm2(
        &self,
        ease_factor: f32,
        interval: f32,
        sm2_retention: f32,
    ) -> MemoryState {
        MemoryState(
            self.0
                .lock()
                .unwrap()
                .memory_state_from_sm2(ease_factor, interval, sm2_retention)
                .unwrap()
                .into(),
        )
    }
    #[frb(sync)]
    pub fn memory_state(&self, item: FSRSItem, starting_state: Option<MemoryState>) -> MemoryState {
        MemoryState(
            self.0
                .lock()
                .unwrap()
                .memory_state(item.0, starting_state.map(|x| x.0.clone()))
                .unwrap()
                .into(),
        )
    }
    #[frb(sync)]
    pub fn to_string(&self) -> String {
        format!("{:?}", self.0.lock().unwrap())
    }
}
#[derive(Debug, Clone, Copy)]
#[frb(opaque)]
pub struct MemoryState(fsrs::MemoryState);

impl MemoryState {
    #[frb(sync)]
    pub fn new(stability: f32, difficulty: f32) -> Self {
        Self(fsrs::MemoryState {
            stability,
            difficulty,
        })
    }
    #[frb(sync)]
    pub fn to_string(&self) -> String {
        format!("{:?}", self.0)
    }
}

#[derive(Debug, Clone)]
#[frb(opaque)]
pub struct NextStates(fsrs::NextStates);
impl NextStates {
    #[frb(sync, getter)]
    pub fn hard(&self) -> ItemState {
        ItemState(self.0.hard.clone())
    }
    #[frb(sync, getter)]
    pub fn good(&self) -> ItemState {
        ItemState(self.0.good.clone())
    }
    #[frb(sync, getter)]
    pub fn easy(&self) -> ItemState {
        ItemState(self.0.easy.clone())
    }
    #[frb(sync, getter)]
    pub fn again(&self) -> ItemState {
        ItemState(self.0.again.clone())
    }
    #[frb(sync)]
    pub fn to_string(&self) -> String {
        format!("{:?}", self.0)
    }
}

#[derive(Debug, Clone)]
#[frb(opaque)]
pub struct ItemState(fsrs::ItemState);

impl ItemState {
    #[frb(sync, getter)]
    pub fn memory(&self) -> MemoryState {
        MemoryState(self.0.memory.clone())
    }
    #[frb(sync, getter)]
    pub fn interval(&self) -> f32 {
        self.0.interval
    }
    #[frb(sync)]
    pub fn to_string(&self) -> String {
        format!("{:?}", self.0)
    }
}

#[derive(Debug, Clone)]
#[frb(opaque)]
pub struct FSRSItem(fsrs::FSRSItem);

impl FSRSItem {
    #[frb(sync)]
    pub fn new(reviews: &[RustAutoOpaque<FSRSReview>]) -> Self {
        Self(fsrs::FSRSItem {
            reviews: reviews.iter().map(|x| x.blocking_read().0).collect(),
        })
    }
    #[frb(sync, getter)]
    pub fn get_reviews(&self) -> Vec<FSRSReview> {
        self.0
            .reviews
            .iter()
            .map(|x| FSRSReview(x.clone()))
            .collect()
    }
    #[frb(sync)]
    pub fn set_reviews(&mut self, other: &[RustAutoOpaque<FSRSReview>]) {
        self.0.reviews = other.iter().map(|x| x.blocking_read().0).collect()
    }
    #[frb(sync, getter)]
    pub fn long_term_review_cnt(&self) -> usize {
        self.0
            .reviews
            .iter()
            .filter(|review| review.delta_t > 0)
            .count()
    }
    #[frb(sync)]
    pub fn to_string(&self) -> String {
        format!("{:?}", self.0)
    }
}

#[derive(Debug, Clone, Copy)]
#[frb(opaque)]
pub struct FSRSReview(fsrs::FSRSReview);

impl FSRSReview {
    #[frb(sync)]
    pub fn new(rating: u32, delta_t: u32) -> Self {
        Self(fsrs::FSRSReview { rating, delta_t })
    }
    #[frb(sync)]
    pub fn to_string(&self) -> String {
        format!("{:?}", self.0)
    }
}

#[frb(sync)]
#[allow(non_snake_case)]
pub const fn DEFAULT_PARAMETERS() -> [f32; 19] {
    [
        0.40255, 1.18385, 3.173, 15.69105, 7.1949, 0.5345, 1.4604, 0.0046, 1.54575, 0.1192,
        1.01925, 1.9395, 0.11, 0.29605, 2.2698, 0.2315, 2.9898, 0.51655, 0.6621,
    ]
}
