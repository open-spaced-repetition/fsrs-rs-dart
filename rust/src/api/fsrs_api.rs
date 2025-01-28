use flutter_rust_bridge::frb;

#[frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

#[derive(Debug, Clone)]
#[frb(opaque)]
pub struct FSRS(fsrs::FSRS);
impl FSRS {
    pub fn new(parameters: Vec<f32>) -> Self {
        Self(fsrs::FSRS::new(Some(&parameters)).unwrap())
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
                .next_states(
                    current_memory_state.map(|x| x.0),
                    desired_retention,
                    days_elapsed,
                )
                .unwrap(),
        )
    }
    pub fn compute_parameters(&self, train_set: Vec<FSRSItem>) -> Vec<f32> {
        self.0
            .compute_parameters(train_set.iter().map(|x| x.0.clone()).collect(), None, true)
            .unwrap_or_default()
    }
    pub fn benchmark(&self, train_set: Vec<FSRSItem>) -> Vec<f32> {
        self.0
            .benchmark(train_set.iter().map(|x| x.0.clone()).collect(), true)
    }
    pub fn memory_state_from_sm2(
        &self,
        ease_factor: f32,
        interval: f32,
        sm2_retention: f32,
    ) -> MemoryState {
        MemoryState(
            self.0
                .memory_state_from_sm2(ease_factor, interval, sm2_retention)
                .unwrap(),
        )
    }
    pub fn memory_state(&self, item: FSRSItem, starting_state: Option<MemoryState>) -> MemoryState {
        MemoryState(
            self.0
                .memory_state(item.0, starting_state.map(|x| x.0))
                .unwrap(),
        )
    }
}
#[derive(Debug, Clone)]
#[frb(opaque)]
pub struct MemoryState(fsrs::MemoryState);

impl MemoryState {
    pub fn new(stability: f32, difficulty: f32) -> Self {
        Self(fsrs::MemoryState {
            stability,
            difficulty,
        })
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
    pub fn __repr__(&self) -> String {
        format!("{:?}", self.0)
    }
}

#[derive(Debug, Clone)]
#[frb(opaque)]
pub struct FSRSItem(fsrs::FSRSItem);

impl FSRSItem {
    #[frb(sync)]
    pub fn new(reviews: Vec<FSRSReview>) -> Self {
        Self(fsrs::FSRSItem {
            reviews: reviews.iter().map(|x| x.0).collect(),
        })
    }
    pub fn get_reviews(&self) -> Vec<FSRSReview> {
        self.0
            .reviews
            .iter()
            .map(|x| FSRSReview(x.clone()))
            .collect()
    }
    pub fn set_reviews(&mut self, other: Vec<FSRSReview>) {
        self.0.reviews = other.iter().map(|x| x.0).collect()
    }

    pub fn long_term_review_cnt(&self) -> usize {
        self.0
            .reviews
            .iter()
            .filter(|review| review.delta_t > 0)
            .count()
    }
    pub fn __repr__(&self) -> String {
        return format!("{:?}", self.0);
    }
}

#[derive(Debug, Clone)]
#[frb(opaque)]
pub struct FSRSReview(fsrs::FSRSReview);

impl FSRSReview {
    #[frb(sync)]
    pub fn new(rating: u32, delta_t: u32) -> Self {
        Self(fsrs::FSRSReview { rating, delta_t })
    }
    pub fn __repr__(&self) -> String {
        return format!("{:?}", self.0);
    }
}

pub const fn DEFAULT_PARAMETERS() -> [f32; 19] {
    [
        0.40255, 1.18385, 3.173, 15.69105, 7.1949, 0.5345, 1.4604, 0.0046, 1.54575, 0.1192,
        1.01925, 1.9395, 0.11, 0.29605, 2.2698, 0.2315, 2.9898, 0.51655, 0.6621,
    ]
}
