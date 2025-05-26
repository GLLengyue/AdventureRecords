import SwiftUI

/// 数据管理器测试视图
/// 用于在应用中运行数据管理测试并显示结果
struct DataManagerTestView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var testResults: [TestResult] = []
    @State private var isRunningTests = false
    @State private var showTestDetails = false
    @State private var selectedTest: TestResult?

    var body: some View {
        NavigationView {
            VStack {
                // 测试结果摘要
                if !testResults.isEmpty {
                    TestSummaryView(results: testResults)
                        .padding()
                }

                // 测试结果列表
                List {
                    if testResults.isEmpty {
                        Text("尚未运行测试")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        ForEach(testResults.indices, id: \.self) { index in
                            TestResultRow(result: testResults[index], index: index)
                                .onTapGesture {
                                    selectedTest = testResults[index]
                                    showTestDetails = true
                                }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())

                // 运行测试按钮
                Button(action: {
                    runTests()
                }) {
                    HStack {
                        Spacer()

                        if isRunningTests {
                            ProgressView()
                                .padding(.trailing, 10)
                        }

                        Text(isRunningTests ? "测试运行中..." : "运行测试")
                            .fontWeight(.semibold)

                        Spacer()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .disabled(isRunningTests)
                .padding(.bottom)
            }
            .navigationTitle("数据管理测试")
            .navigationBarItems(trailing: Button("完成") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showTestDetails) {
                if let test = selectedTest {
                    TestDetailView(result: test)
                }
            }
        }
    }

    /// 运行测试
    private func runTests() {
        isRunningTests = true

        // 在后台线程运行测试
        DispatchQueue.global(qos: .userInitiated).async {
            let results = DataManagerTestRunner.runTests()

            // 在主线程更新UI
            DispatchQueue.main.async {
                testResults = results
                isRunningTests = false
            }
        }
    }
}

/// 测试摘要视图
struct TestSummaryView: View {
    let results: [TestResult]

    private var passedTests: Int {
        results.filter { $0.passed }.count
    }

    private var failedTests: Int {
        results.count - passedTests
    }

    private var passRate: Double {
        Double(passedTests) / Double(results.count) * 100
    }

    var body: some View {
        VStack(spacing: 10) {
            Text("测试摘要")
                .font(.headline)
                .padding(.bottom, 5)

            HStack(spacing: 20) {
                VStack {
                    Text("\(results.count)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("总计")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack {
                    Text("\(passedTests)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("通过")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack {
                    Text("\(failedTests)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    Text("失败")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack {
                    Text(String(format: "%.1f%%", passRate))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(passRate >= 90 ? .green : (passRate >= 70 ? .orange : .red))
                    Text("通过率")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

/// 测试结果行
struct TestResultRow: View {
    let result: TestResult
    let index: Int

    var body: some View {
        HStack {
            Text("\(index + 1).")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .leading)

            VStack(alignment: .leading, spacing: 5) {
                Text(result.name)
                    .font(.headline)

                Text(result.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: result.passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(result.passed ? .green : .red)
                .font(.title3)
        }
        .padding(.vertical, 5)
    }
}

/// 测试详情视图
struct TestDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let result: TestResult

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // 测试状态
                HStack {
                    Image(systemName: result.passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(result.passed ? .green : .red)
                        .font(.largeTitle)

                    VStack(alignment: .leading) {
                        Text(result.passed ? "测试通过" : "测试失败")
                            .font(.headline)

                        Text(result.name)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.leading, 10)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

                // 测试详情
                VStack(alignment: .leading, spacing: 10) {
                    Text("测试详情")
                        .font(.headline)

                    Text(result.message)
                        .font(.body)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }

                // 测试时间
                VStack(alignment: .leading, spacing: 10) {
                    Text("测试时间")
                        .font(.headline)

                    Text(formatDate(result.timestamp))
                        .font(.body)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("测试详情")
            .navigationBarItems(trailing: Button("关闭") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    /// 格式化日期
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}

// 预览
struct DataManagerTestView_Previews: PreviewProvider {
    static var previews: some View {
        DataManagerTestView()
    }
}
